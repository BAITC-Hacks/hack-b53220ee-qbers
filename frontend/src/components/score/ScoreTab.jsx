import { useEffect, useState } from "react";
import { api } from "../../lib/api";
import { LoadingOverlay } from "../ProgressBar";

const fmt = (n) => n.toFixed(1);

function Delta({ before, after, higherBetter = true, decimals = 1 }) {
  const gain = after - before;
  const good = higherBetter ? gain > 0.05 : gain < -0.05;
  const bad = higherBetter ? gain < -0.05 : gain > 0.05;
  return (
    <span className="score-delta">
      {before.toFixed(decimals)} <i className="fa-solid fa-arrow-right" />{" "}
      <strong className={good ? "up" : bad ? "down" : ""}>{after.toFixed(decimals)}</strong>
    </span>
  );
}

export default function ScoreTab({ onPlanUpdated }) {
  const [data, setData] = useState(null);
  const [error, setError] = useState(null);
  const [ai, setAi] = useState({ state: "idle" });
  const [reportState, setReportState] = useState({ state: "idle" });

  const load = () => api("score/").then(setData).catch((e) => setError(e.message));
  useEffect(() => {
    load();
  }, []);

  async function runAllocate() {
    setAi({ state: "running" });
    try {
      const res = await api("ai/allocate/", { method: "POST", body: {} });
      setAi({ state: "done", rationale: res.rationale, split: res.split });
      onPlanUpdated?.();
      load();
    } catch (e) {
      setAi({ state: "error", message: e.data?.error || e.message });
    }
  }

  async function downloadReport() {
    setReportState({ state: "running" });
    try {
      const res = await fetch("/api/ai/report/", { method: "POST", credentials: "same-origin",
        headers: { "X-CSRFToken": document.cookie.match(/csrftoken=([^;]+)/)?.[1] || "" } });
      if (!res.ok) {
        const body = await res.json().catch(() => ({}));
        throw new Error(body.error || res.statusText);
      }
      const blob = await res.blob();
      const url = URL.createObjectURL(blob);
      const a = document.createElement("a");
      a.href = url;
      a.download = "astana-budget-ai-report.pdf";
      a.click();
      URL.revokeObjectURL(url);
      setReportState({ state: "done" });
    } catch (e) {
      setReportState({ state: "error", message: e.message });
    }
  }

  if (!data) {
    return (
      <div className="transport transport-loading">
        {error ? <div className="banner bad"><i className="fa-solid fa-triangle-exclamation" /> {error}</div>
          : <LoadingOverlay done={false} floor={30} label="Computing the district score" />}
      </div>
    );
  }

  const inDataset = data.districts.filter((d) => d.in_dataset);

  return (
    <div className="score-tab">
      <section className="t-card">
        <h4><i className="fa-solid fa-bullseye" /> Final Score — District_Dataset_EN.docx formula</h4>
        <p className="muted small">
          Score = 0.7 × D_avg + 0.3 × min(D_d) − 1.0 × N_crit (pairs below {data.critical}/100), population-weighted over the
          5 districts the dataset covers. "After" applies your current budget scenario's effects (see Method below).
        </p>
        <div className="score-summary">
          <div className="score-box"><span>D_avg (population-weighted)</span><Delta before={data.before.D_avg} after={data.after.D_avg} /></div>
          <div className="score-box"><span>min(D_d) — weakest district</span><Delta before={data.before.min_D} after={data.after.min_D} /></div>
          <div className="score-box"><span>N_crit (pairs &lt; {data.critical})</span><Delta before={data.before.N_crit} after={data.after.N_crit} higherBetter={false} decimals={0} /></div>
          <div className="score-box grand"><span>Final Score</span><Delta before={data.before.score} after={data.after.score} /></div>
        </div>
      </section>

      <section className="t-card">
        <h4><i className="fa-solid fa-robot" /> AI budget allocation</h4>
        <p className="muted small">
          Asks AI to split your total budget across the five areas to raise the Final Score, based on each district's
          weakest indicators. It only sets the five areas' shares — it doesn't place specific stops, schools or trees.
        </p>
        <button className="btn-small" onClick={runAllocate} disabled={ai.state === "running"}>
          <i className={`fa-solid ${ai.state === "running" ? "fa-spinner fa-spin" : "fa-wand-magic-sparkles"}`} /> Use AI to allocate budget
        </button>
        {ai.state === "done" && (
          <div className="ai-result">
            <p><strong>New split:</strong> {Object.entries(ai.split).map(([k, v]) => `${k} ${v.toFixed(0)}%`).join(" · ")}</p>
            <p>{ai.rationale}</p>
          </div>
        )}
        {ai.state === "error" && <p className="t-warn bad"><i className="fa-solid fa-triangle-exclamation" /> {ai.message}</p>}

        <h4><i className="fa-solid fa-file-pdf" /> Downloadable AI report</h4>
        <p className="muted small">A grounded, district-by-district recommendation report (schools, bus stops, trees, utility fixes) as a PDF.</p>
        <button className="btn-small" onClick={downloadReport} disabled={reportState.state === "running"}>
          <i className={`fa-solid ${reportState.state === "running" ? "fa-spinner fa-spin" : "fa-download"}`} /> Download AI report (PDF)
        </button>
        {reportState.state === "error" && <p className="t-warn bad"><i className="fa-solid fa-triangle-exclamation" /> {reportState.message}</p>}
      </section>

      <section className="t-card">
        <h4><i className="fa-solid fa-table" /> Indicators by district (0–100, target 100)</h4>
        <div className="table-scroll">
          <table className="district-table indicators">
            <thead>
              <tr>
                <th>District</th>
                {Object.keys(data.weights).map((k) => <th key={k} title={data.labels[k]}>{k.toUpperCase()}</th>)}
                <th>D_d</th>
              </tr>
            </thead>
            <tbody>
              {inDataset.map((d) => {
                const b = data.before.rows[d.name];
                const a = data.after.rows[d.name];
                return (
                  <tr key={d.name}>
                    <th><i className="swatch" style={{ background: d.color }} /> {d.name}</th>
                    {Object.keys(data.weights).map((k) => (
                      <td key={k} className={a.values[k] < data.critical ? "crit" : ""}>
                        {b.values[k].toFixed(0)}{a.values[k] > b.values[k] + 0.05 ? <> → <strong className="up">{a.values[k].toFixed(0)}</strong></> : ""}
                      </td>
                    ))}
                    <td><strong>{b.D_d.toFixed(1)}{a.D_d > b.D_d + 0.05 ? <> → <strong className="up">{a.D_d.toFixed(1)}</strong></> : ""}</strong></td>
                  </tr>
                );
              })}
            </tbody>
          </table>
        </div>
        <small className="muted">
          {data.districts.find((d) => !d.in_dataset)?.name} isn't in the district dataset (created after it was written), so it's excluded from the Score formula.
          Red cells are below {data.critical}/100 ("critical" — each one costs 1 point off the Final Score).
        </small>
      </section>

      <section className="t-card">
        <h4><i className="fa-solid fa-circle-info" /> Method</h4>
        <p className="muted small">
          Each domain's budget tools move indicators using the docx's own measure catalogue as a conversion rate
          (e.g. lighting/CCTV spend → B1/B2, using measure M10's 12-point cost for +12 B1/+2 B2), scaled by
          <code> your spend ÷ (total budget ÷ 100)</code>. This is a transparent simplification, not an official model —
          <strong> E2 (air quality), S2 (clinics) and C2 (request speed)</strong> have no budget tool in this app yet, so
          they never move. Green space (E1) uses tree count × 4 m²; transport (T1/T2) uses new bus stops/rail stations;
          schools (S1) uses new school/kindergarten spend; utilities (C1) uses city-services fixes.
        </p>
      </section>
    </div>
  );
}
