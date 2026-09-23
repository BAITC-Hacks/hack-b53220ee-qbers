import { useCallback, useEffect, useMemo, useReducer, useRef, useState } from "react";
import { useProgress } from "../../hooks/useProgress";
import { api } from "../../lib/api";
import { districtIndexAt } from "../../lib/geo";
import { expandPlantings, greenAnalysis } from "../../lib/green";
import { formatAmount, fromKzt, kztPerUnit, rateOf, toKzt } from "../../lib/money";
import NumberField from "../NumberField";
import { LoadingOverlay, ProgressBar } from "../ProgressBar";
import { MeasureSelect } from "../transport/CostTable";
import { Meter } from "../transport/CoveragePanel";
import GreeneryMap, { TREE_ICONS } from "./GreeneryMap";

const TREE_SIGN = `data:image/svg+xml;charset=utf-8,${encodeURIComponent(
  '<svg xmlns="http://www.w3.org/2000/svg" width="40" height="40" viewBox="0 0 40 40"><rect x="1" y="1" width="38" height="38" rx="11" fill="#FFFACD" stroke="#006A6D" stroke-width="2" stroke-dasharray="4 3"/><rect x="5" y="5" width="30" height="30" rx="8" fill="#2E7D32" stroke="#fff" stroke-width="2.5"/><path d="M20 9l-7 10h4l-5 7h16l-5-7h4z" fill="#fff"/><rect x="18.5" y="26" width="3" height="5" rx="1" fill="#fff"/></svg>'
)}`;
const fmtInt = (n) => Math.round(n).toLocaleString("en-US");
const m2 = (v) => `${v.toFixed(1)} m²`;
const pct = (v) => `${v.toFixed(1)}%`;

function reducer(s, a) {
  if (a.type === "load") return { ...a.scenario, dirty: false };
  const next = (patch) => ({ ...s, ...patch, dirty: true });
  switch (a.type) {
    case "set":
      return next({ [a.key]: a.value });
    case "cost":
      return next({ costs: { ...s.costs, ...a.patch } });
    case "add":
      return next({ plantings: [...s.plantings, a.planting] });
    case "remove":
      return next({ plantings: s.plantings.filter((_, i) => i !== a.index) });
    case "clear":
      return next({ plantings: [] });
    default:
      return s;
  }
}

const toApi = ({ dirty, updated_at, ...rest }) => rest;

function SaveBadge({ save }) {
  const pctDone = useProgress(save.state !== "saving");
  if (save.state === "saving") return <div className="t-save"><ProgressBar pct={pctDone} label="Saving scenario" /></div>;
  if (save.state === "saved") return <span className="t-save ok"><i className="fa-solid fa-cloud-arrow-up" /> Scenario saved {save.at}</span>;
  if (save.state === "error") return <span className="t-save bad" title={save.message}><i className="fa-solid fa-triangle-exclamation" /> {save.message}</span>;
  return null;
}

export default function GreeneryTab({ plan, rates }) {
  const [data, setData] = useState(null);
  const [scenario, dispatch] = useReducer(reducer, null);
  const [loaded, setLoaded] = useState({});
  const [loadError, setLoadError] = useState(null);
  const [save, setSave] = useState({ state: "idle" });
  const [layers, setLayers] = useState({ regions: true, green: true, need: true, trees: true });
  const [selected, setSelected] = useState(null);
  const [calc, setCalc] = useState({ running: true, floor: 0, result: null });
  const [mass, setMass] = useState({ district: "", count: 10000 });
  const mapRef = useRef(null);
  const saveTimer = useRef(null);

  useEffect(() => {
    const done = (k) => () => setLoaded((l) => ({ ...l, [k]: true }));
    api("greenery/").then(setData).catch((e) => setLoadError(e.message)).finally(done("data"));
    api("greenery/scenario/").then((s) => dispatch({ type: "load", scenario: s })).catch((e) => setLoadError(e.message)).finally(done("scenario"));
  }, []);

  useEffect(() => {
    if (!scenario?.dirty) return undefined;
    clearTimeout(saveTimer.current);
    saveTimer.current = setTimeout(() => {
      setSave({ state: "saving" });
      api("greenery/scenario/", { method: "PUT", body: toApi(scenario) })
        .then((s) => setSave({ state: "saved", at: new Date(s.updated_at).toLocaleTimeString("en-GB", { hour: "2-digit", minute: "2-digit" }) }))
        .catch((e) => setSave({ state: "error", message: e.message }));
    }, 800);
    return () => clearTimeout(saveTimer.current);
  }, [scenario]);

  // ---- analysis: baseline → place trees → after (with a progress bar) ----
  const params = scenario && { radius: scenario.radius, goal: scenario.goal_m2, includeForest: scenario.include_forest };
  const plantingsKey = scenario && JSON.stringify(scenario.plantings);
  const [planted, setPlanted] = useState({ perCell: new Map(), points: [], perDot: 1, total: 0 });

  useEffect(() => {
    if (!data || !scenario) return undefined;
    let cancelled = false;
    setCalc((c) => ({ ...c, running: true, floor: 5 }));
    const t = setTimeout(async () => {
      const footprint = data.tree_footprint_m2;
      const base = greenAnalysis({ data, newTrees: new Map(), footprint, ...params });
      if (cancelled) return;
      setCalc((c) => ({ ...c, floor: 45 }));
      await new Promise((r) => setTimeout(r, 0));
      const trees = expandPlantings({ plantings: scenario.plantings, data, baseline: base.cells, goal: params.goal });
      setCalc((c) => ({ ...c, floor: 70 }));
      await new Promise((r) => setTimeout(r, 0));
      const result = greenAnalysis({ data, newTrees: trees.perCell, footprint, ...params });
      if (cancelled) return;
      setPlanted(trees);
      setCalc({ running: false, floor: 100, result });
    }, 200);
    return () => {
      cancelled = true;
      clearTimeout(t);
    };
  }, [data, plantingsKey, params?.radius, params?.goal, params?.includeForest]); // eslint-disable-line react-hooks/exhaustive-deps

  const onDrop = useCallback(
    (lon, lat) => dispatch({ type: "add", planting: { kind: "drop", lon: +lon.toFixed(6), lat: +lat.toFixed(6), count: scenario?.trees_per_drop || 50 } }),
    [scenario?.trees_per_drop]
  );

  const stats = useMemo(() => {
    if (!data) return null;
    const park = data.green_cells.reduce((a, c) => a + c[2], 0);
    const forest = data.green_cells.reduce((a, c) => a + c[3], 0);
    return { park, forest };
  }, [data]);

  if (Object.keys(loaded).length < 2 || !data || !scenario) {
    return (
      <div className="transport transport-loading">
        {loadError ? (
          <div className="banner bad"><i className="fa-solid fa-triangle-exclamation" /> {loadError}</div>
        ) : (
          <LoadingOverlay done={false} floor={Object.keys(loaded).length * 45} label="Loading green-space data" />
        )}
      </div>
    );
  }

  const r = calc.result;
  const city = r?.city;
  const totalNew = scenario.plantings.reduce((a, p) => a + p.count, 0);
  const footprint = data.tree_footprint_m2;

  // ---- costs, in tenge, then shown in the plan's measure ----
  const c = scenario.costs;
  const setupKzt = totalNew * (c.sapling_kzt + c.planting_kzt);
  const maintYearKzt = scenario.maintenance_quantity * c.maintenance_kzt_month * 12;
  const firstYear = setupKzt + maintYearKzt;
  const mode = plan.mode;
  const budgetValue = plan[mode].allocations.greenery;
  const budgetKzt = mode === "money" ? budgetValue / rateOf(plan.currency, rates) : budgetValue * kztPerUnit(plan, rates);
  const used = budgetKzt > 0 ? (firstYear / budgetKzt) * 100 : 0;
  const inPlan = (kzt) => formatAmount(fromKzt(kzt, mode, plan, rates), { mode, currency: plan.currency });
  const show = (kzt, measure) => fromKzt(kzt, measure, plan, rates);
  const dec = (measure) => (measure === "units" ? 2 : 0);
  const maintShown = show(c.maintenance_period === "year" ? c.maintenance_kzt_month * 12 : c.maintenance_kzt_month, c.maintenance_measure);

  const toggle = (k) => (e) => setLayers((l) => ({ ...l, [k]: e.target.checked }));

  return (
    <div className="transport greenery">
      <aside className="transport-side">
        <section className="t-card t-budget">
          <header>
            <span className="area-caption">Greenery budget</span>
            <SaveBadge save={save} />
          </header>
          <strong className="area-amount">{formatAmount(budgetValue, { mode, currency: plan.currency })}</strong>
          <div className="share">
            <div className={`share-bar ${used > 100 ? "over" : ""}`}><div style={{ width: `${Math.min(100, used)}%` }} /></div>
            <span>First-year cost <strong>{inPlan(firstYear)}</strong> · {used.toFixed(1)}% used</span>
          </div>
          {used > 100 ? (
            <p className="t-warn bad"><i className="fa-solid fa-circle-exclamation" /> Over the greenery budget by {inPlan(firstYear - budgetKzt)}</p>
          ) : (
            <p className="t-warn ok"><i className="fa-solid fa-piggy-bank" /> {inPlan(budgetKzt - firstYear)} left this year</p>
          )}
        </section>

        <section className="t-card">
          <h4><i className="fa-solid fa-leaf" /> Green space today</h4>
          <div className="count-grid">
            <div className="count-box green">
              <i className="fa-solid fa-tree-city" />
              <div>
                <span className="count-label">Parks & lawns</span>
                <strong>{(stats.park / 1e6).toFixed(1)} km²</strong>
                <small>+ {(stats.forest / 1e6).toFixed(1)} km² forest</small>
              </div>
            </div>
            <div className="count-box green">
              <img src={TREE_ICONS.existing} alt="" width="14" height="14" />
              <div>
                <span className="count-label">Mapped trees</span>
                <strong>{fmtInt(data.trees.length)}</strong>
                {totalNew > 0 && <span className="count-added">+{fmtInt(totalNew)} new</span>}
              </div>
            </div>
            <div className="count-box green wide">
              <i className="fa-solid fa-person-shelter" />
              <div>
                <span className="count-label">Residents with ≥{scenario.goal_m2} m² green within {scenario.radius} m</span>
                <strong>{city ? pct(city.shareBefore) : "…"}</strong>
                {city && city.shareAfter > city.shareBefore + 0.05 && <span className="count-added">→ {pct(city.shareAfter)} with new trees</span>}
              </div>
            </div>
          </div>
        </section>

        <section className="t-card">
          <h4><i className="fa-solid fa-hand-pointer" /> Plant trees — drag onto the map</h4>
          <div className="palette single">
            <div
              className="palette-sign"
              draggable
              onDragStart={(e) => {
                e.dataTransfer.setData("application/x-tree", "1");
                e.dataTransfer.effectAllowed = "copy";
                const img = new Image();
                img.src = TREE_SIGN;
                e.dataTransfer.setDragImage(img, 20, 20);
              }}
            >
              <img src={TREE_SIGN} alt="" width="40" height="40" />
              <span>Trees</span>
              <i className="fa-solid fa-grip-vertical" />
            </div>
            <div className="field">
              <span>Trees per drop</span>
              <NumberField value={scenario.trees_per_drop} decimals={0} ariaLabel="Trees per drop"
                onChange={(v) => v >= 1 && dispatch({ type: "set", key: "trees_per_drop", value: v })} />
            </div>
          </div>

          <h4><i className="fa-solid fa-seedling" /> Mass planting in a district</h4>
          <div className="mass-plant">
            <select aria-label="District to plant in" value={mass.district} onChange={(e) => setMass((m) => ({ ...m, district: e.target.value }))}>
              <option value="">Choose district…</option>
              {data.districts.map((d) => <option key={d.name} value={d.name}>{d.name}</option>)}
            </select>
            <NumberField value={mass.count} decimals={0} suffix="trees" ariaLabel="Number of trees to plant"
              onChange={(v) => setMass((m) => ({ ...m, count: v }))} />
            <button
              className="btn-small"
              disabled={!mass.district || mass.count < 1}
              onClick={() => {
                dispatch({ type: "add", planting: { kind: "mass", district: mass.district, count: Math.round(mass.count), seed: Math.floor(Math.random() * 2 ** 31) } });
                setSelected(data.districts.findIndex((d) => d.name === mass.district));
              }}
            >
              <i className="fa-solid fa-tree" /> Plant
            </button>
          </div>
          <small className="muted">Trees go to the blocks with the least green space per resident. Each tree adds {footprint} m².</small>

          {scenario.plantings.length > 0 && (
            <>
              <ul className="new-stops">
                {scenario.plantings.map((p, i) => {
                  const d = p.kind === "drop" ? districtIndexAt(p.lon, p.lat, data.districts) : null;
                  return (
                    <li key={`${p.kind}${i}`}>
                      <img src={TREE_SIGN} alt="" width="24" height="24" />
                      <button className="link-btn plain" onClick={() => {
                        if (p.kind === "drop") mapRef.current?.flyTo(p.lon, p.lat, 15.5);
                        else setSelected(data.districts.findIndex((x) => x.name === p.district));
                      }}>
                        {fmtInt(p.count)} trees
                        <small>{p.kind === "mass" ? `Mass planting · ${p.district}` : `Dropped · ${d >= 0 ? data.districts[d].name : "—"}`}</small>
                      </button>
                      <button className="icon-btn" aria-label={`Remove planting ${i + 1}`} onClick={() => dispatch({ type: "remove", index: i })}>
                        <i className="fa-solid fa-xmark" />
                      </button>
                    </li>
                  );
                })}
              </ul>
              <button className="link-btn" onClick={() => dispatch({ type: "clear" })}>Remove all new trees</button>
            </>
          )}
        </section>
      </aside>

      <div className="transport-main">
        <div className="map-toolbar">
          <label className="switch"><input type="checkbox" checked={layers.regions} onChange={toggle("regions")} /><span /> Districts</label>
          <label className="switch"><input type="checkbox" checked={layers.green} onChange={toggle("green")} /><span /> Green areas</label>
          <label className="switch"><input type="checkbox" checked={layers.need} onChange={toggle("need")} /><span /> Green per resident</label>
          <label className="switch"><input type="checkbox" checked={layers.trees} onChange={toggle("trees")} /><span /> Trees</label>
          <div className="region-picker">
            <button aria-label="Previous district" onClick={() => setSelected((s) => (s == null ? data.districts.length - 1 : s === 0 ? null : s - 1))}>
              <i className="fa-solid fa-chevron-left" />
            </button>
            <select aria-label="Zoom to district" value={selected ?? ""} onChange={(e) => setSelected(e.target.value === "" ? null : Number(e.target.value))}>
              <option value="">All of Astana</option>
              {data.districts.map((d, i) => <option key={d.name} value={i}>{d.name} district</option>)}
            </select>
            <button aria-label="Next district" onClick={() => setSelected((s) => (s == null ? 0 : s === data.districts.length - 1 ? null : s + 1))}>
              <i className="fa-solid fa-chevron-right" />
            </button>
          </div>
        </div>

        <div className="map-wrap">
          <GreeneryMap
            ref={mapRef}
            data={data}
            analysis={r}
            goal={scenario.goal_m2}
            treePoints={planted.points}
            showRegions={layers.regions}
            showGreen={layers.green}
            showNeed={layers.need}
            showTrees={layers.trees}
            selected={selected}
            onDrop={onDrop}
          />
          {selected != null && r && (
            <div className="region-card" style={{ "--region": data.districts[selected].color }} aria-live="polite">
              <button className="icon-btn close" aria-label="Show all of Astana" onClick={() => setSelected(null)}><i className="fa-solid fa-xmark" /></button>
              <span className="region-kk">{data.districts[selected].name_kk} ауданы</span>
              <h4>{data.districts[selected].name} district</h4>
              <div className="region-pop">
                <strong>{fmtInt(data.districts[selected].population)}</strong>
                <span>residents · {data.districts[selected].population_share}% of Astana</span>
              </div>
              <dl>
                <div><dt>Green / resident</dt><dd>{m2(r.byDistrict[selected].perResBefore)}{r.byDistrict[selected].trees ? ` → ${m2(r.byDistrict[selected].perResAfter)}` : ""}</dd></div>
                <div><dt>≥{scenario.goal_m2} m² near home</dt><dd>{pct(r.byDistrict[selected].shareBefore)}{r.byDistrict[selected].trees ? ` → ${pct(r.byDistrict[selected].shareAfter)}` : ""}</dd></div>
                <div><dt>Green area</dt><dd>{(r.byDistrict[selected].greenBefore / 1e4).toFixed(0)} ha</dd></div>
                <div><dt>New trees</dt><dd>{fmtInt(r.byDistrict[selected].trees)}</dd></div>
                {data.districts[selected].e1 != null && <div><dt>Green space (E1)</dt><dd>{data.districts[selected].e1}/100</dd></div>}
              </dl>
              <small>Population: qazatlas.kz, 1 July 2026{data.districts[selected].e1 != null ? " · E1: district dataset" : ""}</small>
            </div>
          )}
          <div className="map-legend">
            {layers.need && (
              <>
                <span><i className="swatch" style={{ background: "#E53935" }} /> &lt;{scenario.goal_m2 / 4} m²</span>
                <span><i className="swatch" style={{ background: "#FFB300" }} /> &lt;{scenario.goal_m2 / 2} m²</span>
                <span><i className="swatch" style={{ background: "#C0CA33" }} /> &lt;{scenario.goal_m2} m²</span>
                <span><i className="swatch" style={{ background: "#43A047" }} /> ≥{scenario.goal_m2} m² per resident nearby</span>
              </>
            )}
            {layers.green && <><span><i className="swatch" style={{ background: "#66BB6A" }} /> Park / lawn</span><span><i className="swatch" style={{ background: "#2E7D32" }} /> Forest</span></>}
            {layers.trees && <><span><img src={TREE_ICONS.existing} alt="" width="9" height="9" /> Tree</span><span><img src={TREE_ICONS.added} alt="" width="11" height="11" /> New{planted.perDot > 1 ? ` (1 dot = ${planted.perDot} trees)` : ""}</span></>}
          </div>
        </div>

        <section className="t-card coverage">
          <header className="coverage-head">
            <h4><i className="fa-solid fa-scale-balanced" /> Green space per resident — before &amp; after</h4>
          </header>
          <div className="coverage-inputs">
            <div className="field"><span>"Near home" means within</span>
              <NumberField value={scenario.radius} decimals={0} suffix="m" ariaLabel="Walking radius in metres"
                onChange={(v) => v >= 100 && v <= 3000 && dispatch({ type: "set", key: "radius", value: v })} /></div>
            <div className="field"><span>Goal: green space per resident</span>
              <NumberField value={scenario.goal_m2} decimals={1} suffix="m²" ariaLabel="Green space goal per resident"
                onChange={(v) => v > 0 && dispatch({ type: "set", key: "goal_m2", value: v })} /></div>
            <label className="switch forest-switch">
              <input type="checkbox" checked={scenario.include_forest} onChange={(e) => dispatch({ type: "set", key: "include_forest", value: e.target.checked })} />
              <span /> Count forest &amp; green belt
            </label>
          </div>
          <small className="muted">The district dataset's E1 indicator scores 100 at ≥20 m² of green space per resident.</small>

          <div className="coverage-body">
            {calc.running && <LoadingOverlay done={false} floor={calc.floor} label="Calculating green space" />}
            <div className="meters">
              <Meter label={`Residents with ≥${scenario.goal_m2} m² within ${scenario.radius} m`} icon="fa-solid fa-person-shelter"
                old={city?.shareBefore ?? 0} now={city?.shareAfter ?? 0} goal={100} />
              <Meter label="City green space per resident" icon="fa-solid fa-leaf" old={city?.perResBefore ?? 0} now={city?.perResAfter ?? 0}
                format={m2} max={Math.max(40, (city?.perResAfter ?? 0) * 1.2)} goal={scenario.goal_m2} />
              <div className="meter">
                <span className="meter-label"><i className="fa-solid fa-tree" /> New trees</span>
                <div className="meter-values"><strong>{fmtInt(totalNew)}</strong><span className="unit">= {fmtInt(totalNew * footprint)} m² of new green</span></div>
                <small className="muted">
                  {fmtInt((city?.population ?? 0) / footprint)} trees would add 1 m² per resident citywide
                </small>
              </div>
            </div>

            <div className="table-scroll">
              <table className="district-table">
                <thead>
                  <tr>
                    <th>District</th>
                    <th>Residents</th>
                    <th>Green area<br /><small>before → after</small></th>
                    <th>m² per resident<br /><small>before → after</small></th>
                    <th>≥{scenario.goal_m2} m² near home<br /><small>before → after</small></th>
                    <th>New trees</th>
                  </tr>
                </thead>
                <tbody>
                  {data.districts.map((d, i) => {
                    const x = r?.byDistrict[i];
                    return (
                      <tr key={d.name}>
                        <th><i className="swatch" style={{ background: d.color }} /> {d.name}</th>
                        <td>{fmtInt(d.population)}</td>
                        <td>{x ? `${(x.greenBefore / 1e4).toFixed(0)} → ` : "—"}<strong className={x?.trees ? "up" : ""}>{x ? `${(x.greenAfter / 1e4).toFixed(x.trees ? 1 : 0)} ha` : ""}</strong></td>
                        <td>{x ? `${m2(x.perResBefore)} → ` : "—"}<strong className={x?.trees ? "up" : ""}>{x ? m2(x.perResAfter) : ""}</strong></td>
                        <td>{x ? `${pct(x.shareBefore)} → ` : "—"}<strong className={x && x.shareAfter > x.shareBefore + 0.05 ? "up" : ""}>{x ? pct(x.shareAfter) : ""}</strong></td>
                        <td className="num">{x ? fmtInt(x.trees) : "—"}</td>
                      </tr>
                    );
                  })}
                </tbody>
              </table>
            </div>
          </div>
        </section>

        <section className="t-card">
          <h4><i className="fa-solid fa-coins" /> Tree costs</h4>
          <p className="muted small">Pre-filled planning estimates — edit them to match nursery and contractor quotes. Amounts in {plan.currency} or units.</p>
          <div className="table-scroll">
            <table className="cost-table">
              <thead>
                <tr><th>Item</th><th>Quantity</th><th>Cost <small>each</small></th><th>Total</th></tr>
              </thead>
              <tbody>
                {[
                  { key: "sapling", label: "Tree (sapling)", qty: totalNew, qtyLabel: "new trees" },
                  { key: "planting", label: "Planting / setup", qty: totalNew, qtyLabel: "new trees" },
                ].map(({ key, label, qty, qtyLabel }) => (
                  <tr key={key}>
                    <th><i className="fa-solid fa-seedling" /> {label}</th>
                    <td className="num">{fmtInt(qty)} <small className="muted">{qtyLabel}</small></td>
                    <td>
                      <div className="cost-input">
                        <NumberField value={show(c[`${key}_kzt`], c[`${key}_measure`])} decimals={dec(c[`${key}_measure`])} ariaLabel={`${label} cost`}
                          onChange={(v) => dispatch({ type: "cost", patch: { [`${key}_kzt`]: toKzt(v, c[`${key}_measure`], plan, rates) } })} />
                        <MeasureSelect value={c[`${key}_measure`]} currency={plan.currency} label={`${label} measure`}
                          onChange={(m) => dispatch({ type: "cost", patch: { [`${key}_measure`]: m } })} />
                      </div>
                    </td>
                    <td className="num">{inPlan(qty * c[`${key}_kzt`])}</td>
                  </tr>
                ))}
                <tr>
                  <th><i className="fa-solid fa-scissors" /> Maintenance <small>pruning, cutting, watering</small></th>
                  <td>
                    <div className="cost-input">
                      <NumberField value={scenario.maintenance_quantity} decimals={0} ariaLabel="Trees needing maintenance"
                        onChange={(v) => dispatch({ type: "set", key: "maintenance_quantity", value: Math.round(v) })} />
                      <small className="muted">trees needing it</small>
                    </div>
                  </td>
                  <td>
                    <div className="cost-input">
                      <NumberField value={maintShown} decimals={dec(c.maintenance_measure)} ariaLabel="Maintenance fee per tree"
                        onChange={(v) => {
                          const kzt = toKzt(v, c.maintenance_measure, plan, rates);
                          dispatch({ type: "cost", patch: { maintenance_kzt_month: c.maintenance_period === "year" ? kzt / 12 : kzt } });
                        }} />
                      <MeasureSelect value={c.maintenance_measure} currency={plan.currency} label="Maintenance measure"
                        onChange={(m) => dispatch({ type: "cost", patch: { maintenance_measure: m } })} />
                      <select className="mini-select" aria-label="Maintenance period" value={c.maintenance_period}
                        onChange={(e) => dispatch({ type: "cost", patch: { maintenance_period: e.target.value } })}>
                        <option value="month">/ month</option>
                        <option value="year">/ year</option>
                      </select>
                    </div>
                  </td>
                  <td className="num">{inPlan(maintYearKzt)} <small className="muted">/ year</small></td>
                </tr>
              </tbody>
              <tfoot>
                <tr><th colSpan={3}>Trees + planting (one-off)</th><td className="num">{inPlan(setupKzt)}</td></tr>
                <tr><th colSpan={3}>Maintenance per year</th><td className="num">{inPlan(maintYearKzt)}</td></tr>
                <tr className="grand"><th colSpan={3}>First-year total</th><td className="num">{inPlan(firstYear)}</td></tr>
              </tfoot>
            </table>
          </div>
        </section>

        <footer className="sources">
          <strong>Sources</strong>
          <ul>
            {data.sources.map((s) => (
              <li key={s.label}>{s.label} — {s.url ? <a href={s.url} target="_blank" rel="noreferrer">{s.cite}</a> : s.cite}</li>
            ))}
            <li>
              Method: green areas are measured on a 40 m grid (overlaps counted once) and summed into ≈200 m blocks. "Near home" divides the green
              space within {scenario.radius} m of each home block by the residents living within the same {scenario.radius} m. Each new tree counts as {footprint} m².
            </li>
          </ul>
        </footer>
      </div>
    </div>
  );
}
