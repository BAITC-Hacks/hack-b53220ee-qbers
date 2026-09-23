import { useCallback, useEffect, useMemo, useReducer, useRef, useState } from "react";
import { api } from "../../lib/api";
import TabScoreStrip from "../score/TabScoreStrip";
import { districtIndexAt, proximity } from "../../lib/geo";
import { fromKzt, formatAmount, kztPerUnit, rateOf } from "../../lib/money";
import { useProgress } from "../../hooks/useProgress";
import { LoadingOverlay, ProgressBar } from "../ProgressBar";
import CostTable, { costSummary } from "./CostTable";
import CoveragePanel from "./CoveragePanel";
import FleetPanel from "./FleetPanel";
import InfrastructurePanel from "./InfrastructurePanel";
import RegionCard from "./RegionCard";
import { SIGNS } from "../../lib/signs";
import TransportMap from "./TransportMap";

function scenarioReducer(s, a) {
  if (a.type === "load") return { ...a.scenario, dirty: false };
  const next = (patch) => ({ ...s, ...patch, dirty: true });
  switch (a.type) {
    case "cost":
      return next({ costs: { ...s.costs, [a.asset]: { ...s.costs[a.asset], ...a.patch } } });
    case "newBuses":
      return next({ new_buses: { ...s.new_buses, [a.route]: Math.max(0, Math.min(500, Math.round(a.value) || 0)) } });
    case "newTrains":
      return next({ new_trains: Math.max(0, Math.min(500, Math.round(a.value) || 0)) });
    case "addStop":
      return next({ new_stops: [...s.new_stops, { kind: a.kind, lon: +a.lon.toFixed(6), lat: +a.lat.toFixed(6) }] });
    case "moveStop":
      return next({ new_stops: s.new_stops.map((x, i) => (i === a.index ? { ...x, lon: +a.lon.toFixed(6), lat: +a.lat.toFixed(6) } : x)) });
    case "removeStop":
      return next({ new_stops: s.new_stops.filter((_, i) => i !== a.index) });
    case "clearStops":
      return next({ new_stops: [] });
    case "distance":
      return next({ distances: { ...s.distances, [a.kind]: a.value } });
    case "goal":
      return next({ goals: { ...s.goals, [a.key]: a.value } });
    case "existing":
      return next({ existing_override: { ...s.existing_override, [a.key]: a.value } });
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

export default function TransportTab({ plan, rates }) {
  const [data, setData] = useState(null);
  const [scenario, dispatch] = useReducer(scenarioReducer, null);
  const [loaded, setLoaded] = useState({});
  const [loadError, setLoadError] = useState(null);
  const [save, setSave] = useState({ state: "idle" });
  const [showRegions, setShowRegions] = useState(true);
  const [showRoutes, setShowRoutes] = useState(true);
  const [showStops, setShowStops] = useState(true);
  const [selected, setSelected] = useState(null);
  const [result, setResult] = useState(null);
  const [calc, setCalc] = useState({ running: false, floor: 0 });
  const mapRef = useRef(null);
  const saveTimer = useRef(null);
  const calcRun = useRef(0);

  // ---- load reference data + saved scenario (each half of the preloader) ----
  useEffect(() => {
    const done = (k) => () => setLoaded((l) => ({ ...l, [k]: true }));
    api("transport/").then(setData).catch((e) => setLoadError(e.message)).finally(done("data"));
    api("transport/scenario/").then((s) => dispatch({ type: "load", scenario: s })).catch((e) => setLoadError(e.message)).finally(done("scenario"));
  }, []);

  // ---- autosave (validated by TransportScenarioForm in Django) ----
  useEffect(() => {
    if (!scenario?.dirty) return undefined;
    clearTimeout(saveTimer.current);
    saveTimer.current = setTimeout(() => {
      setSave({ state: "saving" });
      api("transport/scenario/", { method: "PUT", body: toApi(scenario) })
        .then((s) => setSave({ state: "saved", at: new Date(s.updated_at).toLocaleTimeString("en-GB", { hour: "2-digit", minute: "2-digit" }) }))
        .catch((e) => setSave({ state: "error", message: e.message }));
    }, 800);
    return () => clearTimeout(saveTimer.current);
  }, [scenario]);

  // ---- derived stop lists ----
  const stops = useMemo(() => {
    if (!data || !scenario) return null;
    const busOld = data.bus_stops.map((s) => [s[0], s[1]]);
    const railOld = data.rail_stations.map((s) => [s.lon, s.lat]);
    const newBus = scenario.new_stops.filter((s) => s.kind === "bus").map((s) => [s.lon, s.lat]);
    const newRail = scenario.new_stops.filter((s) => s.kind === "rail").map((s) => [s.lon, s.lat]);
    return { busOld, railOld, busNew: [...busOld, ...newBus], railNew: [...railOld, ...newRail], newBus, newRail };
  }, [data, scenario]);

  // ---- proximity calculation (re-runs when distances or stops change) ----
  const runCalc = useCallback(async () => {
    if (!data || !stops || !scenario) return;
    const run = ++calcRun.current;
    setCalc({ running: true, floor: 0 });
    const res = await proximity({
      cells: data.cells,
      districts: data.districts,
      ...stops,
      busRadius: scenario.distances.bus,
      railRadius: scenario.distances.rail,
      onProgress: (f) => run === calcRun.current && setCalc({ running: true, floor: Math.round(f * 95) }),
    });
    if (run !== calcRun.current) return; // a newer calculation started meanwhile
    setResult(res);
    setCalc({ running: false, floor: 100 });
  }, [data, stops, scenario?.distances.bus, scenario?.distances.rail]); // eslint-disable-line react-hooks/exhaustive-deps

  useEffect(() => {
    const t = setTimeout(runCalc, 250);
    return () => clearTimeout(t);
  }, [runCalc]);

  const onDrop = useCallback((kind, lon, lat) => dispatch({ type: "addStop", kind, lon, lat }), []);
  const onMove = useCallback((index, lon, lat) => dispatch({ type: "moveStop", index, lon, lat }), []);

  const pageDone = Object.keys(loaded).length === 2;
  if (!pageDone || !data || !scenario) {
    return (
      <div className="transport transport-loading">
        {loadError ? (
          <div className="banner bad"><i className="fa-solid fa-triangle-exclamation" /> {loadError}</div>
        ) : (
          <LoadingOverlay done={false} floor={Object.keys(loaded).length * 45} label="Loading transport data" />
        )}
      </div>
    );
  }

  // ---- budget maths in the plan's own measure (currency or units) ----
  const mode = plan.mode;
  const budgetValue = plan[mode].allocations.transport;
  const budgetKzt = mode === "money" ? budgetValue / rateOf(plan.currency, rates) : budgetValue * kztPerUnit(plan, rates);
  const counts = {
    bus_stop: stops.newBus.length,
    rail_station: stops.newRail.length,
    bus: Object.values(scenario.new_buses).reduce((a, b) => a + b, 0),
    train: scenario.new_trains,
  };
  const summary = costSummary(scenario.costs, counts);
  const inPlan = (kzt) => formatAmount(fromKzt(kzt, mode, plan, rates), { mode, currency: plan.currency });
  const firstYear = summary.setup + summary.maintenanceYear;
  const used = budgetKzt > 0 ? (firstYear / budgetKzt) * 100 : 0;

  const existing = {
    bus_stops: data.bus_stops.length,
    rail_stations: data.rail_stations.length,
    rail_only: data.rail_stations.filter((s) => s.kind === "rail").length,
    lrt: data.rail_stations.filter((s) => s.kind === "lrt").length,
    buses: data.routes.reduce((a, r) => a + r.fleet, 0),
  };
  const newByDistrict = data.districts.map(() => ({ bus: 0, rail: 0 }));
  for (const s of scenario.new_stops) {
    const d = districtIndexAt(s.lon, s.lat, data.districts);
    if (d >= 0) newByDistrict[d][s.kind] += 1;
  }

  return (
    <div className="transport">
      <aside className="transport-side">
        <section className="t-card t-budget">
          <header>
            <span className="area-caption">Transport budget</span>
            <SaveBadge save={save} />
          </header>
          <strong className="area-amount">{formatAmount(budgetValue, { mode, currency: plan.currency })}</strong>
          <div className="share">
            <div className={`share-bar ${used > 100 ? "over" : ""}`}><div style={{ width: `${Math.min(100, used)}%` }} /></div>
            <span>
              First-year cost <strong>{inPlan(firstYear)}</strong> · {used.toFixed(1)}% used
            </span>
          </div>
          {used > 100 ? (
            <p className="t-warn bad"><i className="fa-solid fa-circle-exclamation" /> Over the transport budget by {inPlan(firstYear - budgetKzt)}</p>
          ) : (
            <p className="t-warn ok"><i className="fa-solid fa-piggy-bank" /> {inPlan(budgetKzt - firstYear)} left this year</p>
          )}
        </section>

        <InfrastructurePanel
          existing={existing}
          override={scenario.existing_override}
          counts={counts}
          newStops={scenario.new_stops}
          districts={data.districts}
          dispatch={dispatch}
          onFocus={(s) => mapRef.current?.flyTo(s.lon, s.lat, 15)}
        />

        <FleetPanel routes={data.routes} newBuses={scenario.new_buses} newTrains={scenario.new_trains} dispatch={dispatch} />
      </aside>

      <div className="transport-main">
        <div className="map-toolbar">
          <label className="switch">
            <input type="checkbox" checked={showRegions} onChange={(e) => setShowRegions(e.target.checked)} />
            <span /> Districts
          </label>
          <label className="switch">
            <input type="checkbox" checked={showRoutes} onChange={(e) => setShowRoutes(e.target.checked)} />
            <span /> Bus routes
          </label>
          <label className="switch">
            <input type="checkbox" checked={showStops} onChange={(e) => setShowStops(e.target.checked)} />
            <span /> Bus stops
          </label>
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
          <TransportMap
            ref={mapRef}
            data={data}
            newStops={scenario.new_stops}
            showRegions={showRegions}
            showRoutes={showRoutes}
            showStops={showStops}
            selected={selected}
            onDrop={onDrop}
            onMove={onMove}
          />
          {selected != null && (
            <RegionCard
              district={data.districts[selected]}
              index={selected}
              data={data}
              result={result}
              added={newByDistrict[selected]}
              onClose={() => setSelected(null)}
            />
          )}
          <div className="map-legend">
            {showRegions && data.districts.map((d) => (
              <span key={d.name}><i className="swatch" style={{ background: d.color }} /> {d.name}</span>
            ))}
            {showRoutes && data.routes.map((r) => (
              <span key={r.short_name}><i className="line" style={{ background: r.color }} /> Route {r.short_name}</span>
            ))}
            <span><img src={SIGNS.bus} alt="" width="14" height="14" /> Bus stop</span>
            <span><img src={SIGNS.rail} alt="" width="14" height="14" /> Railway</span>
            <span><img src={SIGNS.lrt} alt="" width="14" height="14" /> LRT</span>
            <span><img src={SIGNS.newBus} alt="" width="16" height="16" /> New</span>
          </div>
        </div>

        <CoveragePanel
          data={data}
          scenario={scenario}
          result={result}
          calc={calc}
          existing={existing}
          newByDistrict={newByDistrict}
          dispatch={dispatch}
          onRecalculate={runCalc}
        />

        <CostTable costs={scenario.costs} counts={counts} plan={plan} rates={rates} dispatch={dispatch} summary={summary} />

        <TabScoreStrip indicators={["t1", "t2"]} />

        <footer className="sources">
          <strong>Sources</strong>
          <ul>
            {data.sources.map((s) => (
              <li key={s.label}>
                {s.label} — {s.url ? <a href={s.url} target="_blank" rel="noreferrer">{s.cite}</a> : s.cite}
              </li>
            ))}
            <li>
              Coverage model: residents are placed on a ≈200 m grid in proportion to residential floor area (OSM buildings) and
              scaled to each district's population; distances are straight-line. Costs are editable planning estimates.
            </li>
          </ul>
        </footer>
      </div>
    </div>
  );
}
