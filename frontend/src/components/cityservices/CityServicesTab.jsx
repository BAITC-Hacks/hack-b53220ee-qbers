import { useEffect, useMemo, useReducer, useRef, useState } from "react";
import { useProgress } from "../../hooks/useProgress";
import { api } from "../../lib/api";
import TabScoreStrip from "../score/TabScoreStrip";
import { districtIndexAt } from "../../lib/geo";
import { formatAmount, fromKzt, kztPerUnit, rateOf, toKzt } from "../../lib/money";
import { UTIL_COLORS, UTIL_NEW_SIGNS } from "../../lib/signs";
import { PaletteItem } from "../dnd/DndProvider";
import BarChart from "../BarChart";
import DistrictCard from "../districts/DistrictCard";
import RegionPicker from "../districts/RegionPicker";
import NumberField from "../NumberField";
import { LoadingOverlay, ProgressBar } from "../ProgressBar";
import { MeasureSelect } from "../transport/CostTable";
import CityServicesMap from "./CityServicesMap";

const UTILITY_LABELS = { electricity: "Electricity", water: "Water", heating: "Heating", sewage: "Sewage" };
const FIX_LABELS = { water_pipe: "Water pipe", electrical_wiring: "Electrical wiring", heater: "Heating (substation)" };
const fmtInt = (n) => Math.round(n).toLocaleString("en-US");

function reducer(s, a) {
  if (a.type === "load") return { ...a.scenario, dirty: false };
  const next = (patch) => ({ ...s, ...patch, dirty: true });
  switch (a.type) {
    case "place":
      return next({ fixes: [...s.fixes, { kind: a.kind, lon: +a.lon.toFixed(6), lat: +a.lat.toFixed(6) }] });
    case "move":
      return next({ fixes: s.fixes.map((f, i) => (i === a.index ? { ...f, lon: +a.lon.toFixed(6), lat: +a.lat.toFixed(6) } : f)) });
    case "remove":
      return next({ fixes: s.fixes.filter((_, i) => i !== a.index) });
    case "cost":
      return next({ costs: { ...s.costs, [a.kind]: { ...s.costs[a.kind], ...a.patch } } });
    default:
      return s;
  }
}
const toApi = ({ dirty, updated_at, ...rest }) => rest;

function SaveBadge({ save }) {
  const pct = useProgress(save.state !== "saving");
  if (save.state === "saving") return <div className="t-save"><ProgressBar pct={pct} label="Saving scenario" /></div>;
  if (save.state === "saved") return <span className="t-save ok"><i className="fa-solid fa-cloud-arrow-up" /> Scenario saved {save.at}</span>;
  if (save.state === "error") return <span className="t-save bad" title={save.message}><i className="fa-solid fa-triangle-exclamation" /> {save.message}</span>;
  return null;
}

export default function CityServicesTab({ plan, rates }) {
  const [data, setData] = useState(null);
  const [scenario, dispatch] = useReducer(reducer, null);
  const [loaded, setLoaded] = useState({});
  const [loadError, setLoadError] = useState(null);
  const [save, setSave] = useState({ state: "idle" });
  const [utility, setUtility] = useState("electricity");
  const [selected, setSelected] = useState(null);
  const [score, setScore] = useState(null);
  const saveTimer = useRef(null);

  useEffect(() => {
    const done = (k) => () => setLoaded((l) => ({ ...l, [k]: true }));
    api("cityservices/").then(setData).catch((e) => setLoadError(e.message)).finally(done("data"));
    api("cityservices/scenario/").then((s) => dispatch({ type: "load", scenario: s })).catch((e) => setLoadError(e.message)).finally(done("scenario"));
  }, []);

  useEffect(() => {
    if (!scenario?.dirty) return undefined;
    clearTimeout(saveTimer.current);
    saveTimer.current = setTimeout(() => {
      setSave({ state: "saving" });
      api("cityservices/scenario/", { method: "PUT", body: toApi(scenario) })
        .then((s) => {
          setSave({ state: "saved", at: new Date(s.updated_at).toLocaleTimeString("en-GB", { hour: "2-digit", minute: "2-digit" }) });
          api("score/").then(setScore).catch(() => {});
        })
        .catch((e) => setSave({ state: "error", message: e.message }));
    }, 800);
    return () => clearTimeout(saveTimer.current);
  }, [scenario]);

  useEffect(() => {
    api("score/").then(setScore).catch(() => {});
  }, []);

  if (Object.keys(loaded).length < 2 || !data || !scenario) {
    return (
      <div className="transport transport-loading">
        {loadError ? <div className="banner bad"><i className="fa-solid fa-triangle-exclamation" /> {loadError}</div>
          : <LoadingOverlay done={false} floor={Object.keys(loaded).length * 45} label="Loading city services data" />}
      </div>
    );
  }

  const counts = { water_pipe: 0, electrical_wiring: 0, heater: 0 };
  for (const f of scenario.fixes) counts[f.kind] += 1;
  const costs = scenario.costs;
  const setupKzt = Object.keys(costs).reduce((a, k) => a + counts[k] * costs[k].setup_kzt, 0);
  const maintYear = Object.keys(costs).reduce((a, k) => a + counts[k] * costs[k].maintenance_kzt_month * 12, 0);
  const firstYear = setupKzt + maintYear;
  const mode = plan.mode;
  const budgetValue = plan[mode].allocations.city;
  const budgetKzt = mode === "money" ? budgetValue / rateOf(plan.currency, rates) : budgetValue * kztPerUnit(plan, rates);
  const used = budgetKzt > 0 ? (firstYear / budgetKzt) * 100 : 0;
  const inPlan = (kzt) => formatAmount(fromKzt(kzt, mode, plan, rates), { mode, currency: plan.currency });
  const show$ = (kzt, measure) => fromKzt(kzt, measure, plan, rates);
  const dec = (m) => (m === "units" ? 2 : 0);

  const years = Object.keys(data.series[utility] || {}).map(Number).sort((a, b) => a - b);
  const chartData = years.map((y) => ({ label: String(y), value: data.series[utility][y].count }));
  const cityTotal = chartData.reduce((a, d) => a + d.value, 0);
  const latestYear = years[years.length - 1];

  const byDistrictFixes = data.districts.map(() => 0);
  for (const f of scenario.fixes) {
    const d = districtIndexAt(f.lon, f.lat, data.districts);
    if (d >= 0) byDistrictFixes[d] += 1;
  }

  const c1Before = score?.before.rows;
  const c1After = score?.after.rows;

  return (
    <div className="transport cityservices">
      <aside className="transport-side">
        <section className="t-card t-budget">
          <header><span className="area-caption">City services budget</span><SaveBadge save={save} /></header>
          <strong className="area-amount">{formatAmount(budgetValue, { mode, currency: plan.currency })}</strong>
          <div className="share">
            <div className={`share-bar ${used > 100 ? "over" : ""}`}><div style={{ width: `${Math.min(100, used)}%` }} /></div>
            <span>First-year cost <strong>{inPlan(firstYear)}</strong> · {used.toFixed(1)}% used</span>
          </div>
          {used > 100
            ? <p className="t-warn bad"><i className="fa-solid fa-circle-exclamation" /> Over the city-services budget by {inPlan(firstYear - budgetKzt)}</p>
            : <p className="t-warn ok"><i className="fa-solid fa-piggy-bank" /> {inPlan(budgetKzt - firstYear)} left this year</p>}
        </section>

        <section className="t-card">
          <h4><i className="fa-solid fa-triangle-exclamation" /> Utility complaints ({latestYear})</h4>
          <div className="count-grid">
            {Object.keys(UTILITY_LABELS).map((u) => {
              const years = data.series[u] ? Object.keys(data.series[u]).map(Number) : [];
              const last = years.length ? Math.max(...years) : null;
              const v = last != null ? data.series[u][last].count : 0;
              return (
                <div key={u} className="count-box" style={{ borderColor: UTIL_COLORS[u.startsWith("water") ? "water_pipe" : u === "electricity" ? "electrical_wiring" : "heater"] }}>
                  <i className="fa-solid fa-bolt" style={{ color: "#00838F" }} />
                  <div><span className="count-label">{UTILITY_LABELS[u]}</span><strong>{fmtInt(v)}</strong><small>appeals, {last || "—"}</small></div>
                </div>
              );
            })}
          </div>
          <p className="notice warn">
            <i className="fa-solid fa-circle-info" /> {data.note}
          </p>
        </section>

        <section className="t-card">
          <h4><i className="fa-solid fa-hand-pointer" /> Fix — drag onto the map</h4>
          <div className="palette three">
            {["water_pipe", "electrical_wiring", "heater"].map((k) => (
              <PaletteItem key={k} id={`palette-${k}`} kind={k} label={FIX_LABELS[k]} icon={UTIL_NEW_SIGNS[k]} />
            ))}
          </div>
          <small className="muted">Each fix estimates repairing/upgrading one section of that utility in the district you drop it in. Drag placed fixes to move them.</small>
          {scenario.fixes.length > 0 && (
            <ul className="new-stops">
              {scenario.fixes.map((f, i) => {
                const d = districtIndexAt(f.lon, f.lat, data.districts);
                return (
                  <li key={`${f.lon},${f.lat},${i}`}>
                    <img src={UTIL_NEW_SIGNS[f.kind]} alt="" width="24" height="24" />
                    <span className="plain-label">{FIX_LABELS[f.kind]} #{i + 1}<small>{d >= 0 ? data.districts[d].name : "—"}</small></span>
                    <button className="icon-btn" aria-label={`Remove fix ${i + 1}`} onClick={() => dispatch({ type: "remove", index: i })}><i className="fa-solid fa-xmark" /></button>
                  </li>
                );
              })}
            </ul>
          )}
        </section>
      </aside>

      <div className="transport-main">
        <div className="map-toolbar">
          <span className="muted small" style={{ margin: 0 }}>Heatmap:</span>
          <select className="mini-select" aria-label="Heatmap utility" value={utility} onChange={(e) => setUtility(e.target.value)}>
            {Object.entries(UTILITY_LABELS).map(([k, l]) => <option key={k} value={k}>{l} complaints</option>)}
          </select>
          <RegionPicker districts={data.districts} selected={selected} onChange={setSelected} />
        </div>

        <div className="map-wrap">
          <CityServicesMap data={data} utility={utility} selected={selected} onSelect={setSelected} fixes={scenario.fixes} dispatch={dispatch} />
          {selected != null && (
            <DistrictCard
              district={data.districts[selected]}
              indicators={["c1", "c2"]}
              onClose={() => setSelected(null)}
              extra={[["Fixes placed here", byDistrictFixes[selected]]]}
            />
          )}
          <div className="map-legend">
            <span><i className="swatch" style={{ background: "#3588fd" }} /> low</span>
            <span><i className="swatch" style={{ background: "#ffc94d" }} /> medium</span>
            <span><i className="swatch" style={{ background: "#f50007" }} /> high (estimated complaint density)</span>
          </div>
        </div>

        {score && (
          <section className="t-card score-mini">
            <h4><i className="fa-solid fa-scale-balanced" /> Score impact (C1 utility reliability)</h4>
            <div className="score-mini-row">
              <span>City Final Score</span>
              <strong>{score.before.score.toFixed(1)}</strong>
              <i className="fa-solid fa-arrow-right" />
              <strong className={score.after.score > score.before.score + 0.01 ? "up" : ""}>{score.after.score.toFixed(1)} / 100</strong>
            </div>
            <div className="table-scroll">
              <table className="district-table">
                <thead><tr><th>District</th><th>C1 utility reliability<br /><small>before → after</small></th></tr></thead>
                <tbody>
                  {data.districts.filter((d) => c1Before?.[d.name]).map((d) => (
                    <tr key={d.name}>
                      <th><i className="swatch" style={{ background: d.color }} /> {d.name}</th>
                      <td>{c1Before[d.name].values.c1.toFixed(0)} → <strong className={c1After[d.name].values.c1 > c1Before[d.name].values.c1 + 0.05 ? "up" : ""}>{c1After[d.name].values.c1.toFixed(0)}</strong></td>
                    </tr>
                  ))}
                </tbody>
              </table>
            </div>
            <small className="muted">Full breakdown of all 10 indicators is in the <strong>Indicators</strong> tab.</small>
          </section>
        )}

        <section className="t-card">
          <h4><i className="fa-solid fa-chart-column" /> {UTILITY_LABELS[utility]} appeals per year</h4>
          <p className="muted small">Residents' appeals to Astana's monitoring centre — the closest public proxy for outages; there's no open dataset of actual fault counts or locations.</p>
          {chartData.length ? <BarChart data={chartData} color={UTIL_COLORS.electrical_wiring} /> : <p className="muted">Not enough published data for {UTILITY_LABELS[utility].toLowerCase()} to chart.</p>}
          <small className="muted">Total {UTILITY_LABELS[utility].toLowerCase()} appeals shown: {fmtInt(cityTotal)}.</small>
        </section>

        <section className="t-card">
          <h4><i className="fa-solid fa-coins" /> Costs</h4>
          <p className="muted small">Pre-filled planning estimates — edit to match real quotes. Amounts in {plan.currency} or units, maintenance per month or per year.</p>
          <div className="table-scroll">
            <table className="cost-table">
              <thead><tr><th>Item</th><th>New</th><th>Purchase / setup <small>each</small></th><th>Maintenance <small>each</small></th><th>Setup total</th><th>Maintenance / year</th></tr></thead>
              <tbody>
                {["water_pipe", "electrical_wiring", "heater"].map((k) => {
                  const c = costs[k];
                  const maintShown = show$(c.maintenance_period === "year" ? c.maintenance_kzt_month * 12 : c.maintenance_kzt_month, c.maintenance_measure);
                  return (
                    <tr key={k}>
                      <th><img src={UTIL_NEW_SIGNS[k]} alt="" width="18" height="18" /> {FIX_LABELS[k]}</th>
                      <td className="num">{counts[k]}</td>
                      <td>
                        <div className="cost-input">
                          <NumberField value={show$(c.setup_kzt, c.setup_measure)} decimals={dec(c.setup_measure)} ariaLabel={`${FIX_LABELS[k]} setup cost`}
                            onChange={(v) => dispatch({ type: "cost", kind: k, patch: { setup_kzt: toKzt(v, c.setup_measure, plan, rates) } })} />
                          <MeasureSelect value={c.setup_measure} currency={plan.currency} label={`${FIX_LABELS[k]} setup measure`}
                            onChange={(m) => dispatch({ type: "cost", kind: k, patch: { setup_measure: m } })} />
                        </div>
                      </td>
                      <td>
                        <div className="cost-input">
                          <NumberField value={maintShown} decimals={dec(c.maintenance_measure)} ariaLabel={`${FIX_LABELS[k]} maintenance cost`}
                            onChange={(v) => {
                              const kzt = toKzt(v, c.maintenance_measure, plan, rates);
                              dispatch({ type: "cost", kind: k, patch: { maintenance_kzt_month: c.maintenance_period === "year" ? kzt / 12 : kzt } });
                            }} />
                          <MeasureSelect value={c.maintenance_measure} currency={plan.currency} label={`${FIX_LABELS[k]} maintenance measure`}
                            onChange={(m) => dispatch({ type: "cost", kind: k, patch: { maintenance_measure: m } })} />
                          <select className="mini-select" aria-label={`${FIX_LABELS[k]} maintenance period`} value={c.maintenance_period}
                            onChange={(e) => dispatch({ type: "cost", kind: k, patch: { maintenance_period: e.target.value } })}>
                            <option value="month">/ month</option><option value="year">/ year</option>
                          </select>
                        </div>
                      </td>
                      <td className="num">{inPlan(counts[k] * c.setup_kzt)}</td>
                      <td className="num">{inPlan(counts[k] * c.maintenance_kzt_month * 12)}</td>
                    </tr>
                  );
                })}
              </tbody>
              <tfoot>
                <tr><th colSpan={4}>Purchase / setup</th><td className="num" colSpan={2}>{inPlan(setupKzt)}</td></tr>
                <tr><th colSpan={4}>Maintenance per year</th><td className="num" colSpan={2}>{inPlan(maintYear)}</td></tr>
                <tr className="grand"><th colSpan={4}>First-year total</th><td className="num" colSpan={2}>{inPlan(firstYear)}</td></tr>
              </tfoot>
            </table>
          </div>
        </section>

        <TabScoreStrip indicators={["c1", "c2"]} />

        <footer className="sources">
          <strong>Sources</strong>
          <ul>{data.sources.map((s) => <li key={s.label}>{s.label} — {s.url ? <a href={s.url} target="_blank" rel="noreferrer">{s.cite}</a> : s.cite}</li>)}</ul>
        </footer>
      </div>
    </div>
  );
}
