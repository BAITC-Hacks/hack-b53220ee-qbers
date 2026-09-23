"""AI features: budget-split suggestion and the downloadable PDF report.

Both call OpenAI's Chat Completions API directly over HTTPS (no SDK dependency).
The API key lives only in `.env` / Django settings — it is never sent to the browser.
"""
import io
import json
import re

import requests
from django.conf import settings
from fpdf import FPDF

from .docxscore import CATEGORY, LABELS

OPENAI_URL = "https://api.openai.com/v1/chat/completions"
AREAS = ["transport", "greenery", "social", "safety", "city"]
AREA_LABELS = {"transport": "Transport", "greenery": "Greenery", "social": "Social services", "safety": "Safety", "city": "City services"}


class AIError(RuntimeError):
    pass


def _chat(messages, max_tokens=900):
    if not settings.OPENAI_API_KEY:
        raise AIError("OPENAI_API_KEY is not set in .env.")
    try:
        res = requests.post(
            OPENAI_URL,
            headers={"Authorization": f"Bearer {settings.OPENAI_API_KEY}", "Content-Type": "application/json"},
            # reasoning_effort=minimal: gpt-5-* models spend completion tokens on hidden reasoning
            # before the visible answer; without capping it, max_completion_tokens can be used up
            # by reasoning alone and the JSON content comes back empty.
            json={"model": settings.OPENAI_MODEL, "messages": messages, "max_completion_tokens": max_tokens,
                 "reasoning_effort": "minimal", "response_format": {"type": "json_object"}},
            timeout=90,
        )
    except requests.RequestException as exc:
        raise AIError(f"Could not reach OpenAI: {exc}") from exc
    if res.status_code != 200:
        raise AIError(f"OpenAI returned an error (HTTP {res.status_code}): {res.text[:300]}")
    body = res.json()
    try:
        content = body["choices"][0]["message"]["content"]
    except (KeyError, IndexError) as exc:
        raise AIError(f"Unexpected OpenAI response: {body}") from exc
    try:
        return json.loads(content)
    except json.JSONDecodeError:
        match = re.search(r"\{.*\}", content, re.S)
        if match:
            return json.loads(match.group(0))
        raise AIError("OpenAI's reply wasn't valid JSON.")


def _district_summary(score_result, districts):
    lines = []
    for name, row in score_result["districts"].items():
        weak = sorted(row["values"].items(), key=lambda kv: kv[1])[:3]
        weak_s = ", ".join(f"{LABELS[k]} {v:.0f}/100" for k, v in weak)
        pop = next((d.population for d in districts if d.name == name), None)
        lines.append(f"- {name} (pop {pop:,}, D_d={row['D_d']:.1f}/100): weakest = {weak_s}")
    return "\n".join(lines)


def suggest_allocation(score_result, districts, current_split):
    """Ask the AI how to split the total budget across the 5 areas to raise the Score."""
    prompt = f"""You are advising on Astana's city budget, split across five areas: Transport, Greenery,
Social services, Safety, City services. Below is each district's weakest indicators (0-100 scale, from an
official planning dataset) and the city's current Final Score components.

{_district_summary(score_result, districts)}

City Final Score = 0.7*D_avg + 0.3*min(D_d) - 1*N_crit(pairs below 40).
D_avg={score_result['D_avg']:.2f}  min(D_d)={score_result['min_D']:.2f}  N_crit={score_result['N_crit']}  Score={score_result['score']:.2f}

Current split (%): {json.dumps(current_split)}

Suggest a new split (percent of the total budget, five numbers summing to exactly 100) across
transport, greenery, social, safety, city that would most improve the Final Score — prioritise the
weakest districts and indicators, and don't defund an area to zero unless it is clearly not the
bottleneck. Reply with ONLY a JSON object: {{"split": {{"transport": n, "greenery": n, "social": n,
"safety": n, "city": n}}, "rationale": "2-4 sentences, citing specific districts/indicators/numbers above"}}"""
    data = _chat([{"role": "user", "content": prompt}], max_tokens=500)
    split = {k: float(data.get("split", {}).get(k, 20)) for k in AREAS}
    total = sum(split.values()) or 100
    split = {k: v / total * 100 for k, v in split.items()}
    return split, str(data.get("rationale", "")).strip()


def generate_report_content(score_result, districts, summaries):
    """Ask the AI for a structured, district-grounded recommendation report."""
    prompt = f"""You are writing a short civic-planning report for Astana's city budget dashboard.
Ground every recommendation in the numbers given below — never invent statistics, addresses or coordinates.

DISTRICT INDICATORS (0-100, weakest 3 shown; official planning dataset):
{_district_summary(score_result, districts)}

CITY SCORE: D_avg={score_result['D_avg']:.2f} min(D_d)={score_result['min_D']:.2f} N_crit={score_result['N_crit']} Score={score_result['score']:.2f}

CURRENT PLAN (what the user has already added, by domain):
{json.dumps(summaries, ensure_ascii=False, indent=None)}

The ONLY actions this dashboard can actually place and cost are:
  - bus stops, rail/LRT stations, extra buses (affects T1/T2)
  - trees (affects E1, a little E2)
  - schools, kindergartens (affects S1)
  - street lamps, CCTV cameras, speed cameras (affects B1/B2)
  - water-pipe, electrical-wiring and district-heating fixes (affects C1)
There is NO tool for clinics/healthcare (S2), air quality/emissions (E2 beyond the tree effect), or the
speed of resolving requests (C2) — if one of a district's weakest indicators is S2, E2 or C2, say so
plainly (e.g. "no budget tool for this yet") instead of inventing a clinic or monitoring-station action.

Write a report as JSON with this exact shape:
{{"summary": "2-3 sentence overview of the city's biggest gaps",
  "districts": [{{"name": "...", "priority": "1-2 sentences on this district's biggest gap",
                 "actions": ["only from the list above, e.g. 'Add 2 schools' or 'Add 3 bus stops', or a note that no tool exists for this gap", "action 2", "action 3"]}}, ... one entry per district ...],
  "citywide": ["2-4 citywide recommendations using only the tools above"],
  "closing": "1-2 sentence closing note on budget trade-offs, mentioning any indicator this dashboard can't act on"}}
Keep actions concrete but district-level only (no fake street addresses). Use the district names exactly as given."""
    return _chat([{"role": "user", "content": prompt}], max_tokens=1600)


_PDF_REPLACEMENTS = {
    "—": "-", "–": "-", "‘": "'", "’": "'", "“": '"', "”": '"',
    "…": "...", "→": "->", "•": "-", "₸": "KZT ",
}


def _pdf_safe(text):
    """fpdf2's built-in fonts are Latin-1 only; the AI's text (and our own dashes/arrows) often
    isn't. Swap common punctuation for ASCII, then drop anything else Latin-1 can't hold."""
    text = str(text)
    for bad, good in _PDF_REPLACEMENTS.items():
        text = text.replace(bad, good)
    return text.encode("latin-1", "replace").decode("latin-1")


def render_pdf(report, score_result, plan_summary):
    pdf = FPDF()
    pdf.set_auto_page_break(auto=True, margin=18)
    pdf.add_page()

    # fpdf2's multi_cell leaves the cursor wherever the last line ended (often near the right
    # margin), not back at the left margin like cell(ln=True) does — the next call then has
    # almost no width left and raises "Not enough horizontal space". Reset x every time.
    _cell, _multi_cell = pdf.cell, pdf.multi_cell

    def cell(*a, **kw):
        pdf.set_x(pdf.l_margin)
        return _cell(*a, **kw)

    def multi_cell(*a, **kw):
        pdf.set_x(pdf.l_margin)
        return _multi_cell(*a, **kw)

    pdf.cell, pdf.multi_cell = cell, multi_cell
    pdf.set_font("Helvetica", "B", 18)
    pdf.set_text_color(0, 106, 109)
    pdf.cell(0, 12, _pdf_safe("Astana Budget Planner - AI Report"), ln=True)
    pdf.set_font("Helvetica", "", 10)
    pdf.set_text_color(90, 90, 90)
    pdf.cell(0, 6, _pdf_safe("Generated by AI (OpenAI) from the district dataset and your current plan."), ln=True)
    pdf.ln(4)

    pdf.set_text_color(20, 20, 20)
    pdf.set_font("Helvetica", "B", 13)
    pdf.cell(0, 8, _pdf_safe(f"City Score: {score_result['score']:.1f}  (D_avg {score_result['D_avg']:.1f} / min district {score_result['min_D']:.1f} / {score_result['N_crit']} critical pairs)"), ln=True)
    pdf.set_font("Helvetica", "", 11)
    pdf.multi_cell(0, 6, _pdf_safe(report.get("summary", "")))
    pdf.ln(2)

    pdf.set_font("Helvetica", "", 10)
    pdf.multi_cell(0, 5, _pdf_safe("Budget: " + plan_summary))
    pdf.ln(4)

    for d in report.get("districts", []):
        pdf.set_font("Helvetica", "B", 12)
        pdf.set_text_color(0, 106, 109)
        pdf.cell(0, 8, _pdf_safe(d.get("name", "")), ln=True)
        pdf.set_text_color(20, 20, 20)
        pdf.set_font("Helvetica", "I", 10)
        pdf.multi_cell(0, 5, _pdf_safe(d.get("priority", "")))
        pdf.set_font("Helvetica", "", 10)
        for a in d.get("actions", []):
            pdf.multi_cell(0, 5, _pdf_safe(f"  -  {a}"))
        pdf.ln(2)

    if report.get("citywide"):
        pdf.set_font("Helvetica", "B", 12)
        pdf.set_text_color(0, 106, 109)
        pdf.cell(0, 8, _pdf_safe("Citywide recommendations"), ln=True)
        pdf.set_text_color(20, 20, 20)
        pdf.set_font("Helvetica", "", 10)
        for a in report["citywide"]:
            pdf.multi_cell(0, 5, _pdf_safe(f"  -  {a}"))
        pdf.ln(2)

    if report.get("closing"):
        pdf.set_font("Helvetica", "", 10)
        pdf.multi_cell(0, 5, _pdf_safe(report["closing"]))

    pdf.ln(6)
    pdf.set_font("Helvetica", "", 8)
    pdf.set_text_color(120, 120, 120)
    pdf.multi_cell(0, 4, _pdf_safe("Method: indicator scores follow District_Dataset_EN.docx's formula and measure "
                        "catalogue, applied to your current scenario (see the Score tab's methodology note). "
                        "This report is AI-generated commentary on that model, not an official city document."))

    return bytes(pdf.output())
