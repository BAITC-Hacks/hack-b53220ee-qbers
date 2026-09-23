import json
from datetime import timedelta

import django
import requests
from django.conf import settings
from django.contrib.auth import get_user_model, login, logout
from django.db import connection
from django.http import HttpResponse, JsonResponse
from django.utils import timezone
from django.utils.dateparse import parse_datetime
from django.views.decorators.csrf import ensure_csrf_cookie
from django.views.decorators.http import require_GET, require_http_methods, require_POST
from google.auth.transport import requests as google_requests
from google.oauth2 import id_token

from .budget import DEFAULT_MONEY_TOTAL, DEFAULT_UNITS_TOTAL, default_section
from .forms import BudgetPlanForm
from .greenery import GreeneryScenarioForm, default_scenario as default_greenery, reference_payload as greenery_payload
from .cityservices import CityServiceScenarioForm, default_scenario as default_city, reference_payload as city_payload
from .education import EducationScenarioForm, default_scenario as default_education, reference_payload as education_payload
from .models import (BudgetPlan, CityServiceScenario, District, EducationScenario, ExchangeRates, GreeneryScenario,
                     SafetyScenario, TransportScenario)
from . import ai as ai_module
from . import translate as translate_module
from . import docxscore
from .greenery import default_scenario as default_greenery
from .safety import default_scenario as default_safety
from .transport import default_scenario as default_transport
from .safety import SafetyScenarioForm, default_scenario as default_safety, district_payload, reference_payload as safety_payload, references
from .transport import TransportScenarioForm, default_scenario, reference_payload


def _json_body(request):
    try:
        return json.loads(request.body or b"{}")
    except json.JSONDecodeError:
        return {}


def _user_payload(user):
    if not user.is_authenticated:
        return None
    return {"email": user.email, "name": user.get_full_name() or user.username}


@require_GET
def health(request):
    try:
        with connection.cursor() as cursor:
            cursor.execute("SELECT version()")
            db_version = cursor.fetchone()[0].split(",")[0]
        db_ok = True
    except Exception as exc:  # surface the reason on the page
        db_version, db_ok = str(exc), False
    return JsonResponse(
        {
            "django": django.get_version(),
            "database": {
                "ok": db_ok,
                "version": db_version,
                "host": f"{settings.DATABASES['default']['HOST']}:{settings.DATABASES['default']['PORT']}",
                "name": settings.DATABASES["default"]["NAME"],
            },
            "currency_api_key_loaded": bool(settings.CURRENCYAPI_KEY),
        }
    )


@require_GET
@ensure_csrf_cookie
def csrf(request):
    return JsonResponse({"ok": True})


# ---------------------------------------------------------------------------
# Budget plan — one current plan, validated by BudgetPlanForm, stored in Postgres
# ---------------------------------------------------------------------------
def _current_plan():
    plan = BudgetPlan.objects.order_by("-updated_at").first()
    if plan is None:
        plan = BudgetPlan.objects.create(
            money=_stringify(default_section(DEFAULT_MONEY_TOTAL, 2)),
            units=_stringify(default_section(DEFAULT_UNITS_TOTAL, 0)),
        )
    return plan


def _stringify(section):
    return {
        "total": str(section["total"]),
        "split": section["split"],
        "allocations": {k: str(v) for k, v in section["allocations"].items()},
    }


def _plan_payload(plan):
    return {
        "mode": plan.mode,
        "currency": plan.currency,
        "money": plan.money,
        "units": plan.units,
        "updated_at": plan.updated_at.isoformat(),
    }


@require_http_methods(["GET", "PUT"])
def plan(request):
    current = _current_plan()
    if request.method == "PUT":
        form = BudgetPlanForm(_json_body(request))
        if not form.is_valid():
            errors = [e for field in form.errors.values() for e in field]
            return JsonResponse({"error": " ".join(errors), "errors": form.errors}, status=400)
        for field in ("mode", "currency", "money", "units"):
            setattr(current, field, form.cleaned_data[field])
        current.save()
    return JsonResponse(_plan_payload(current))


# ---------------------------------------------------------------------------
# Currency rates — proxied so the key stays server-side, cached to save quota
# ---------------------------------------------------------------------------
def _rates_payload(snapshot, cached, warning=None):
    body = {
        "base": snapshot.base,
        "rates": {**snapshot.rates, snapshot.base: 1},
        "source_updated_at": snapshot.source_updated_at.isoformat() if snapshot.source_updated_at else None,
        "fetched_at": snapshot.fetched_at.isoformat(),
        "cached": cached,
    }
    if warning:
        body["warning"] = warning
    return body


@require_GET
def currency(request):
    latest = ExchangeRates.objects.filter(base="KZT").order_by("-fetched_at").first()
    max_age = timedelta(hours=settings.CURRENCY_CACHE_HOURS)
    if latest and timezone.now() - latest.fetched_at < max_age:
        return JsonResponse(_rates_payload(latest, cached=True))
    if not settings.CURRENCYAPI_KEY:
        if latest:
            return JsonResponse(_rates_payload(latest, cached=True, warning="CURRENCYAPI_KEY missing; using saved rates."))
        return JsonResponse({"error": "CURRENCYAPI_KEY is not set in .env."}, status=503)
    try:
        res = requests.get(
            "https://api.currencyapi.com/v3/latest",
            params={"apikey": settings.CURRENCYAPI_KEY, "base_currency": "KZT"},
            timeout=10,
        )
        res.raise_for_status()
        body = res.json()
        rates = {code: item["value"] for code, item in body["data"].items()}
    except (requests.RequestException, KeyError, ValueError) as exc:
        if latest:  # stale beats nothing
            return JsonResponse(_rates_payload(latest, cached=True, warning=f"Live rates unavailable ({exc}); using saved rates."))
        return JsonResponse({"error": f"Could not load exchange rates: {exc}"}, status=502)
    snapshot = ExchangeRates.objects.create(
        base="KZT", rates=rates, source_updated_at=parse_datetime(body.get("meta", {}).get("last_updated_at", "") or "")
    )
    return JsonResponse(_rates_payload(snapshot, cached=False))


# ---------------------------------------------------------------------------
# Transport tab
# ---------------------------------------------------------------------------
@require_GET
def transport_data(request):
    payload = reference_payload()
    if not payload["districts"]:
        return JsonResponse({"error": "No map data yet — run: npm run data:load (or restart npm start, which loads it)"}, status=503)
    return JsonResponse(payload)


@require_http_methods(["GET", "PUT"])
def transport_scenario(request):
    scenario = TransportScenario.objects.order_by("-updated_at").first()
    if scenario is None:
        scenario = TransportScenario.objects.create(data=default_scenario())
    if request.method == "PUT":
        form = TransportScenarioForm(_json_body(request))
        if not form.is_valid():
            errors = [e for field in form.errors.values() for e in field]
            return JsonResponse({"error": " ".join(errors), "errors": form.errors}, status=400)
        scenario.data = form.cleaned_data
        scenario.save()
    return JsonResponse({**scenario.data, "updated_at": scenario.updated_at.isoformat()})


# ---------------------------------------------------------------------------
# Greenery tab
# ---------------------------------------------------------------------------
@require_GET
def greenery_data(request):
    payload = greenery_payload()
    if not payload["green_cells"]:
        return JsonResponse({"error": "No greenery data yet — run: npm run data:load (or restart npm start)"}, status=503)
    return JsonResponse(payload)


@require_http_methods(["GET", "PUT"])
def greenery_scenario(request):
    scenario = GreeneryScenario.objects.order_by("-updated_at").first()
    if scenario is None:
        scenario = GreeneryScenario.objects.create(data=default_greenery())
    if request.method == "PUT":
        form = GreeneryScenarioForm(_json_body(request))
        if not form.is_valid():
            errors = [e for field in form.errors.values() for e in field]
            return JsonResponse({"error": " ".join(errors), "errors": form.errors}, status=400)
        scenario.data = form.cleaned_data
        scenario.save()
    return JsonResponse({**scenario.data, "updated_at": scenario.updated_at.isoformat()})


# ---------------------------------------------------------------------------
# Safety tab + shared district data (Social / City services tabs)
# ---------------------------------------------------------------------------
@require_GET
def districts_data(request):
    districts = list(District.objects.all())
    if not districts:
        return JsonResponse({"error": "No map data yet — run: npm run data:load (or restart npm start)"}, status=503)
    return JsonResponse({"districts": district_payload(districts), "references": references()})


@require_GET
def safety_data(request):
    payload = safety_payload()
    if not payload["places"]:
        return JsonResponse({"error": "No safety data yet — run: npm run data:load (or restart npm start)"}, status=503)
    return JsonResponse(payload)


@require_http_methods(["GET", "PUT"])
def safety_scenario(request):
    scenario = SafetyScenario.objects.order_by("-updated_at").first()
    if scenario is None:
        scenario = SafetyScenario.objects.create(data=default_safety())
    if request.method == "PUT":
        form = SafetyScenarioForm(_json_body(request))
        if not form.is_valid():
            errors = [e for field in form.errors.values() for e in field]
            return JsonResponse({"error": " ".join(errors), "errors": form.errors}, status=400)
        scenario.data = form.cleaned_data
        scenario.save()
    return JsonResponse({**scenario.data, "updated_at": scenario.updated_at.isoformat()})


# ---------------------------------------------------------------------------
# Social services tab — schools & kindergartens
# ---------------------------------------------------------------------------
@require_GET
def education_data(request):
    payload = education_payload()
    if not payload["places"]:
        return JsonResponse({"error": "No schools data yet — run: npm run data:load (or restart npm start)"}, status=503)
    return JsonResponse(payload)


@require_http_methods(["GET", "PUT"])
def education_scenario(request):
    scenario = EducationScenario.objects.order_by("-updated_at").first()
    if scenario is None:
        scenario = EducationScenario.objects.create(data=default_education())
    if request.method == "PUT":
        form = EducationScenarioForm(_json_body(request))
        if not form.is_valid():
            errors = [e for field in form.errors.values() for e in field]
            return JsonResponse({"error": " ".join(errors), "errors": form.errors}, status=400)
        scenario.data = form.cleaned_data
        scenario.save()
    return JsonResponse({**scenario.data, "updated_at": scenario.updated_at.isoformat()})


# ---------------------------------------------------------------------------
# City services tab — utility complaints (ikomekastana.kz) + fixes
# ---------------------------------------------------------------------------
@require_GET
def cityservices_data(request):
    payload = city_payload()
    if not payload["districts"]:
        return JsonResponse({"error": "No map data yet — run: npm run data:load (or restart npm start)"}, status=503)
    return JsonResponse(payload)


@require_http_methods(["GET", "PUT"])
def cityservices_scenario(request):
    scenario = CityServiceScenario.objects.order_by("-updated_at").first()
    if scenario is None:
        scenario = CityServiceScenario.objects.create(data=default_city())
    if request.method == "PUT":
        form = CityServiceScenarioForm(_json_body(request))
        if not form.is_valid():
            errors = [e for field in form.errors.values() for e in field]
            return JsonResponse({"error": " ".join(errors), "errors": form.errors}, status=400)
        scenario.data = form.cleaned_data
        scenario.save()
    return JsonResponse({**scenario.data, "updated_at": scenario.updated_at.isoformat()})


# ---------------------------------------------------------------------------
# Score tab (District_Dataset_EN.docx formula) + AI features
# ---------------------------------------------------------------------------
def _latest(model, default_fn):
    obj = model.objects.order_by("-updated_at").first()
    return obj.data if obj else default_fn()


def _current_scenarios():
    return {
        "transport": _latest(TransportScenario, default_transport),
        "greenery": _latest(GreeneryScenario, default_greenery),
        "safety": _latest(SafetyScenario, default_safety),
        "education": _latest(EducationScenario, default_education),
        "city": _latest(CityServiceScenario, default_city),
    }


def _score_now():
    districts = list(District.objects.all())
    by_name = {d.name: d for d in districts}
    plan = BudgetPlan.objects.order_by("-updated_at").first()
    total_kzt = float(plan.money["total"]) if plan else 0.0
    unit_kzt = total_kzt / 100
    scen = _current_scenarios()
    effects = docxscore.project_indicators(
        by_name, unit_kzt, transport=scen["transport"], greenery=scen["greenery"], safety=scen["safety"],
        education=scen["education"], city=scen["city"],
    )
    after = docxscore.apply_effects(districts, effects)
    before = docxscore.score(by_name)
    after_score = docxscore.score(by_name, after)
    return districts, by_name, before, after_score, effects, plan, scen


@require_GET
def score_data(request):
    districts, by_name, before, after, effects, plan, scen = _score_now()
    if not districts:
        return JsonResponse({"error": "No map data yet — run: npm run data:load (or restart npm start)"}, status=503)

    def rows(result):
        return {n: {"values": r["values"], "D_d": r["D_d"], "share": r["share"]} for n, r in result["districts"].items()}

    return JsonResponse({
        "districts": [{"name": d.name, "name_kk": d.name_kk, "color": d.color, "population": d.population,
                      "in_dataset": d.docx_population_share is not None} for d in districts],
        "weights": docxscore.WEIGHTS, "labels": docxscore.LABELS, "categories": docxscore.CATEGORY, "critical": docxscore.CRITICAL,
        "before": {"rows": rows(before), "D_avg": before["D_avg"], "min_D": before["min_D"], "N_crit": before["N_crit"], "score": before["score"]},
        "after": {"rows": rows(after), "D_avg": after["D_avg"], "min_D": after["min_D"], "N_crit": after["N_crit"], "score": after["score"]},
    })


def _plan_split_pct(plan):
    total = float(plan.money["total"]) or 1
    return {k: float(plan.money["allocations"][k]) / total * 100 for k in ("transport", "greenery", "social", "safety", "city")}


@require_POST
def ai_allocate(request):
    districts, by_name, before, after, effects, plan, scen = _score_now()
    if plan is None:
        return JsonResponse({"error": "No budget plan yet."}, status=503)
    try:
        split, rationale = ai_module.suggest_allocation(after, districts, _plan_split_pct(plan))
    except ai_module.AIError as exc:
        return JsonResponse({"error": str(exc)}, status=502)

    from decimal import Decimal
    for mode, section, total in (("money", plan.money, Decimal(plan.money["total"])), ("units", plan.units, Decimal(plan.units["total"]))):
        decimals = 2 if mode == "money" else 0
        allocations = {}
        remaining = total
        keys = ["transport", "greenery", "social", "safety", "city"]
        for k in keys[:-1]:
            v = (total * Decimal(str(split[k])) / 100).quantize(Decimal(10) ** -decimals)
            allocations[k] = str(v)
            remaining -= v
        allocations[keys[-1]] = str(remaining.quantize(Decimal(10) ** -decimals))
        section["split"] = "custom"
        section["allocations"] = allocations
    plan.save()
    return JsonResponse({"plan": {"mode": plan.mode, "currency": plan.currency, "money": plan.money, "units": plan.units,
                                 "updated_at": plan.updated_at.isoformat()}, "split": split, "rationale": rationale})


@require_POST
def ai_report(request):
    districts, by_name, before, after, effects, plan, scen = _score_now()
    if not districts:
        return JsonResponse({"error": "No map data yet."}, status=503)
    summaries = {
        "transport": {"new_bus_stops": sum(1 for s in scen["transport"].get("new_stops", []) if s.get("kind") == "bus"),
                     "new_rail_stations": sum(1 for s in scen["transport"].get("new_stops", []) if s.get("kind") == "rail"),
                     "new_buses": sum((scen["transport"].get("new_buses") or {}).values())},
        "greenery": {"new_trees": sum(p.get("count", 0) for p in scen["greenery"].get("plantings", []))},
        "safety": {"placed": len(scen["safety"].get("placements", [])),
                  "added": scen["safety"].get("added", {})},
        "education": {"placed": len(scen["education"].get("placements", [])), "added": scen["education"].get("added", {})},
        "city": {"fixes": len(scen["city"].get("fixes", []))},
    }
    try:
        report = ai_module.generate_report_content(after, districts, summaries)
    except ai_module.AIError as exc:
        return JsonResponse({"error": str(exc)}, status=502)
    plan_summary = ""
    if plan:
        plan_summary = (f"{plan.mode} mode, total {plan.money['total']} {plan.currency} / {plan.units['total']} units, "
                        f"split {json.dumps(plan.money['allocations'])}")
    pdf_bytes = ai_module.render_pdf(report, after, plan_summary)
    response = HttpResponse(pdf_bytes, content_type="application/pdf")
    response["Content-Disposition"] = 'attachment; filename="astana-budget-ai-report.pdf"'
    return response


@require_POST
def translate_view(request):
    body = _json_body(request)
    texts = body.get("texts")
    target = body.get("target")
    if not isinstance(texts, list) or not texts or len(texts) > 500:
        return JsonResponse({"error": "'texts' must be a list of 1-500 strings."}, status=400)
    if not all(isinstance(t, str) and len(t) <= 4000 for t in texts):
        return JsonResponse({"error": "Each text must be a string of at most 4000 characters."}, status=400)
    translations, error = translate_module.translate_batch(texts, target)
    if error:
        return JsonResponse({"error": error}, status=502)
    return JsonResponse({"translations": translations})


@require_POST
def google_login(request):
    credential = _json_body(request).get("credential")
    if not credential:
        return JsonResponse({"error": "Missing credential"}, status=400)
    try:
        info = id_token.verify_oauth2_token(
            credential, google_requests.Request(), settings.GOOGLE_OAUTH_CLIENT_ID
        )
    except ValueError as exc:
        return JsonResponse({"error": f"Invalid Google token: {exc}"}, status=401)

    User = get_user_model()
    user, _ = User.objects.get_or_create(
        username=info["email"],
        defaults={
            "email": info["email"],
            "first_name": info.get("given_name", ""),
            "last_name": info.get("family_name", ""),
        },
    )
    login(request, user)
    return JsonResponse({"user": _user_payload(user), "picture": info.get("picture")})


@require_GET
def me(request):
    return JsonResponse({"user": _user_payload(request.user)})


@require_POST
def logout_view(request):
    logout(request)
    return JsonResponse({"ok": True})
