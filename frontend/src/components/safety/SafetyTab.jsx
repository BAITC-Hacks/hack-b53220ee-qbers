import { useEffect, useMemo, useReducer, useRef, useState } from "react";
import { useProgress } from "../../hooks/useProgress";
import { api } from "../../lib/api";
import { createDraggableMarker } from "../../lib/dragMarker";
import { districtIndexAt } from "../../lib/geo";
import { formatAmount, fromKzt, kztPerUnit, rateOf, toKzt } from "../../lib/money";
import { SAFETY_COLORS, SAFETY_NEW_SIGNS, SAFETY_SIGNS } from "../../lib/signs";
import { PaletteItem } from "../dnd/DndProvider";
import DistrictCard from "../districts/DistrictCard";
import DistrictMap from "../districts/DistrictMap";
import RegionPicker from "../districts/RegionPicker";
import NumberField from "../NumberField";
import { LoadingOverlay, ProgressBar } from "../ProgressBar";
import { MeasureSelect } from "../transport/CostTable";

const KIND_LABELS = {
  fire_station: "Fire station", police_station: "Police department", police_post: "Local police post",
  lamp: "Street lamp", speed_camera: "Speed camera", cctv: "CCTV camera",
};
const VEHICLE_LABELS = {
  fire_truck: "Fire truck", ambulance: "Ambulance", police_car: "Police car", riot_vehicle: "Riot-control vehicle", snow_plough: "Snow plough",
};
const VEHICLE_ICONS = {
  fire_truck: "fa-solid fa-truck-droplet", ambulance: "fa-solid fa-truck-medical", police_car: "fa-solid fa-car-on",
  riot_vehicle: "fa-solid fa-truck-field", snow_plough: "fa-solid fa-snowplow",
};
// District_Dataset_EN.docx measures used to project B1/B2 (budget of 100 ≙ your total budget):
//  M10 Lighting & cameras: cost 12 → B1 +12, B2 +2      M11 Safe crossings: cost 10 → B2 +12
const M10 = { cost: 12, b1: 12, b2: 2 };
const M11 = { cost: 10, b2: 12 };
const fmtInt = (n) => Math.round(n).toLocaleString("en-US");
const esc = (s) => String(s ?? "").replace(/[&<>"']/g, (c) => `&#${c.charCodeAt(0)};`);

function reducer(s, a) {
  if (a.type === "load") return { ...a.scenario, dirty: false };
  const next = (patch) => ({ ...s, ...patch, dirty: true });
  switch (a.type) {
    case "place":
      return next({ placements: [...s.placements, { kind: a.kind, lon: +a.lon.toFixed(6), lat: +a.lat.toFixed(6) }] });
    case "move":
      return next({ placements: s.placements.map((p, i) => (i === a.index ? { ...p, lon: +a.lon.toFixed(6), lat: +a.lat.toFixed(6) } : p)) });
    case "unplace":
      return next({ placements: s.placements.filter((_, i) => i !== a.index) });
    case "added":
      return next({ added: { ...s.added, [a.district]: { ...s.added[a.district], [a.kind]: Math.max(0, Math.round(a.value) || 0) } } });
    case "vehicle":
      return next({ vehicles: { ...s.vehicles, [a.district]: { ...s.vehicles[a.district], [a.kind]: Math.max(0, Math.round(a.value) || 0) } } });
    case "cost":
      return next({ costs: { ...s.costs, [a.asset]: { ...s.costs[a.asset], ...a.patch } } });
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

/** Markers for existing places + the user's draggable placements. */
function SafetyLayers({ map, data, show, placements, dispatch }) {
  const markers = useRef([]);
  const placed = useRef([]);
  const popup = useRef(null);
  const openedAt = useRef(0);
  const [loading, setLoading] = useState({ done: false, floor: 0 });

  const openPopup = (coordinates, html) => {
    openedAt.current = Date.now();
    popup.current?.destroy();
    popup.current = new window.mapgl.HtmlMarker(map, { coordinates, html: `<div class="map-popup">${html}</div>`, zIndex: 1000 });
  };

  useEffect(() => {
    const close = () => {
      if (Date.now() - openedAt.current < 250) return;
      popup.current?.destroy();
      popup.current = null;
    };
    map.on("click", close);
    return () => {
      map.off("click", close);
      popup.current?.destroy();
    };
  }, [map]);

  useEffect(() => {
    let cancelled = false;
    markers.current.forEach((m) => m.destroy());
    markers.current = [];
    const visible = data.places.filter(([kind]) => show[kind]);
    setLoading({ done: false, floor: 10 });
    (async () => {
      for (let i = 0; i < visible.length; i++) {
        const [kind, lon, lat, d, name, address, source] = visible[i];
        const big = kind === "fire_station" || kind === "police_station";
        const size = big ? 26 : 18;
        const mk = new window.mapgl.Marker(map, { coordinates: [lon, lat], icon: SAFETY_SIGNS[kind], size: [size, size], anchor: [size / 2, size / 2], zIndex: big ? 25 : 15 });
        mk.on("click", () => openPopup([lon, lat], `<strong>${esc(name || KIND_LABELS[kind])}</strong><span>${KIND_LABELS[kind]} · ${esc(data.districts[d].name)}</span>${address ? `<span>${esc(address)}</span>` : ""}<span>Source: ${source === "2gis" ? "2GIS" : "OpenStreetMap"}</span>`));
        markers.current.push(mk);
        if (i % 100 === 99) {
          setLoading({ done: false, floor: 10 + Math.round((i / visible.length) * 85) });
          await new Promise((r) => setTimeout(r, 0));
          if (cancelled) return;
        }
      }
      if (!cancelled) setLoading({ done: true, floor: 100 });
    })();
    return () => {
      cancelled = true;
    };
  }, [map, data, show]); // eslint-disable-line react-hooks/exhaustive-deps

  useEffect(() => {
    placed.current.forEach((m) => m.destroy());
    placed.current = placements.map((p, i) =>
      createDraggableMarker(map, {
        coordinates: [p.lon, p.lat], icon: SAFETY_NEW_SIGNS[p.kind], size: 30, zIndex: 40,
        title: `New ${KIND_LABELS[p.kind].toLowerCase()} — drag to move`,
        onMoveEnd: ([lon, lat]) => dispatch({ type: "move", index: i, lon, lat }),
        onClick: () => openPopup([p.lon, p.lat], `<strong>New ${KIND_LABELS[p.kind].toLowerCase()} #${i + 1}</strong><span>Drag it to move · remove it in the sidebar.</span>`),
      })
    );
    return () => placed.current.forEach((m) => m.destroy());
  }, [map, placements]); // eslint-disable-line react-hooks/exhaustive-deps

  useEffect(() => () => markers.current.forEach((m) => m.destroy()), []);
  return loading.done ? null : <LoadingOverlay done={false} floor={loading.floor} label="Placing stations, lamps & cameras" className="is-compact map-layer-loader" />;
}

export default function SafetyTab({ plan, rates }) {
  const [data, setData] = useState(null);
  const [scenario, dispatch] = useReducer(reducer, null);
  const [loaded, setLoaded] = useState({});
  const [loadError, setLoadError] = useState(null);
  const [save, setSave] = useState({ state: "idle" });
  const [selected, setSelected] = useState(null);
  const [showRegions, setShowRegions] = useState(true);
  const [show, setShow] = useState({ fire_station: true, police_station: true, police_post: true, lamp: true, speed_camera: true, cctv: true });
  const saveTimer = useRef(null);

  useEffect(() => {
    const done = (k) => () => setLoaded((l) => ({ ...l, [k]: true }));
    api("safety/").then(setData).catch((e) => setLoadError(e.message)).finally(done("data"));
    api("safety/scenario/").then((s) => dispatch({ type: "load", scenario: s })).catch((e) => setLoadError(e.message)).finally(done("scenario"));
  }, []);

  useEffect(() => {
    if (!scenario?.dirty) return undefined;
    clearTimeout(saveTimer.current);
    saveTimer.current = setTimeout(() => {
      setSave({ state: "saving" });
      api("safety/scenario/", { method: "PUT", body: toApi(scenario) })
        .then((s) => setSave({ state: "saved", at: new Date(s.updated_at).toLocaleTimeString("en-GB", { hour: "2-digit", minute: "2-digit" }) }))
        .catch((e) => setSave({ state: "error", message: e.message }));
    }, 800);
    return () => clearTimeout(saveTimer.current);
  }, [scenario]);

  const counts = useMemo(() => {
    if (!data) return null;
    const byKind = {};
    const byDistrict = data.districts.map(() => ({}));
    for (const [kind, , , d] of data.places) {
      byKind[kind] = (byKind[kind] || 0) + 1;
      byDistrict[d][kind] = (byDistrict[d][kind] || 0) + 1;
    }
    return { byKind, byDistrict };
  }, [data]);

  if (Object.keys(loaded).length < 2 || !data || !scenario) {
    return (
      <div className="transport transport-loading">
        {loadError ? <div className="banner bad"><i className="fa-solid fa-triangle-exclamation" /> {loadError}</div>
          : <LoadingOverlay done={false} floor={Object.keys(loaded).length * 45} label="Loading safety data" />}
      </div>
    );
  }

  // ---- quantities per district (map placements + bulk additions) ----
  const names = data.districts.map((d) => d.name);
  const newInfra = names.map((name) => ({ ...scenario.added[name] }));
  for (const p of scenario.placements) {
    const d = districtIndexAt(p.lon, p.lat, data.districts);
    if (d >= 0) newInfra[d][p.kind] = (newInfra[d][p.kind] || 0) + 1;
  }
  const qty = {};
  for (const k of data.infra) qty[k] = newInfra.reduce((a, x) => a + (x[k] || 0), 0);
  for (const k of data.vehicles) qty[k] = names.reduce((a, n) => a + (scenario.vehicles[n]?.[k] || 0), 0);

  // ---- costs ----
  const costs = scenario.costs;
  const setupKzt = Object.keys(costs).reduce((a, k) => a + (qty[k] || 0) * costs[k].setup_kzt, 0);
  const maintYear = Object.keys(costs).reduce((a, k) => a + (qty[k] || 0) * costs[k].maintenance_kzt_month * 12, 0);
  const firstYear = setupKzt + maintYear;
  const mode = plan.mode;
  const budgetValue = plan[mode].allocations.safety;
  const budgetKzt = mode === "money" ? budgetValue / rateOf(plan.currency, rates) : budgetValue * kztPerUnit(plan, rates);
  const used = budgetKzt > 0 ? (firstYear / budgetKzt) * 100 : 0;
  const inPlan = (kzt) => formatAmount(fromKzt(kzt, mode, plan, rates), { mode, currency: plan.currency });

  // ---- B1/B2 projection from the dataset's measures ----
  const totalBudgetKzt = plan.money.total / rateOf(plan.currency, rates);
  const docxUnitKzt = totalBudgetKzt / 100;
  const projection = data.districts.map((d, i) => {
    const lightSpend = (newInfra[i].lamp || 0) * costs.lamp.setup_kzt + (newInfra[i].cctv || 0) * costs.cctv.setup_kzt;
    const roadSpend = (newInfra[i].speed_camera || 0) * costs.speed_camera.setup_kzt;
    const m10 = lightSpend / docxUnitKzt / M10.cost;
    const m11 = roadSpend / docxUnitKzt / M11.cost;
    const b1 = d.indicators.b1;
    const b2 = d.indicators.b2;
    return {
      b1, b2,
      b1After: b1 == null ? null : Math.min(100, b1 + m10 * M10.b1),
      b2After: b2 == null ? null : Math.min(100, b2 + m10 * M10.b2 + m11 * M11.b2),
      deaths: (d.population * data.references.road_deaths_rate.value) / 100_000,
    };
  });

  const refs = data.references;
  const rate = refs.road_deaths_rate;
  const toggle = (k) => (e) => setShow((s) => ({ ...s, [k]: e.target.checked }));
  const show$ = (kzt, measure) => fromKzt(kzt, measure, plan, rates);
  const dec = (m) => (m === "units" ? 2 : 0);

  const NO_DATA = [
    ["cctv", "CCTV cameras", "fa-solid fa-video", `Only ${counts.byKind.cctv || 0} mapped in OpenStreetMap; the city's Safe City camera count isn't published.`],
    ["fire_truck", "Fire trucks", VEHICLE_ICONS.fire_truck, "Fleet size not published."],
    ["ambulance", "Ambulances", VEHICLE_ICONS.ambulance, "Fleet size not published."],
    ["police_car", "Police cars", VEHICLE_ICONS.police_car, "Fleet size not published."],
    ["riot_vehicle", "Riot-control vehicles", VEHICLE_ICONS.riot_vehicle, "Fleet size not published."],
    ["snow_plough", "Snow ploughs", VEHICLE_ICONS.snow_plough, "Fleet size not published."],
  ];

  return (
    <div className="transport safety">
      <aside className="transport-side">
        <section className="t-card t-budget">
          <header><span className="area-caption">Safety budget</span><SaveBadge save={save} /></header>
          <strong className="area-amount">{formatAmount(budgetValue, { mode, currency: plan.currency })}</strong>
          <div className="share">
            <div className={`share-bar ${used > 100 ? "over" : ""}`}><div style={{ width: `${Math.min(100, used)}%` }} /></div>
            <span>First-year cost <strong>{inPlan(firstYear)}</strong> · {used.toFixed(1)}% used</span>
          </div>
          {used > 100
            ? <p className="t-warn bad"><i className="fa-solid fa-circle-exclamation" /> Over the safety budget by {inPlan(firstYear - budgetKzt)}</p>
            : <p className="t-warn ok"><i className="fa-solid fa-piggy-bank" /> {inPlan(budgetKzt - firstYear)} left this year</p>}
        </section>

        <section className="t-card">
          <h4><i className="fa-solid fa-map-location-dot" /> On the map today</h4>
          <div className="count-grid three">
            {["fire_station", "police_station", "police_post", "lamp", "speed_camera", "cctv"].map((k) => (
              <div key={k} className="count-box">
                <img src={SAFETY_SIGNS[k]} alt="" width="26" height="26" />
                <div>
                  <span className="count-label">{KIND_LABELS[k]}s</span>
                  <strong>{fmtInt(counts.byKind[k] || 0)}</strong>
                  {qty[k] > 0 && <span className="count-added">+{fmtInt(qty[k])} new</span>}
                  <small>{["lamp", "speed_camera", "cctv"].includes(k) ? "OSM · incomplete" : "2GIS"}</small>
                </div>
              </div>
            ))}
          </div>
          <p className="notice warn">
            <i className="fa-solid fa-triangle-exclamation" /> Street lamps, speed cameras and CCTV are barely mapped in open data
            (e.g. {counts.byKind.lamp} lamps for a city of 1.7 million). The city's own GIS portal doesn't publish these layers.
          </p>
        </section>

        <section className="t-card">
          <h4><i className="fa-solid fa-circle-question" /> No open data yet</h4>
          <ul className="no-data">
            {NO_DATA.map(([k, label, icon, note]) => (
              <li key={k}>
                <i className={icon} />
                <div><strong>{label}</strong><small>{note}</small></div>
                <span className="badge">No open data</span>
              </li>
            ))}
          </ul>
        </section>

        <section className="t-card">
          <h4><i className="fa-solid fa-hand-pointer" /> Add — drag onto the map</h4>
          <div className="palette three">
            <PaletteItem id="palette-lamp" kind="lamp" label="Lamp post" icon={SAFETY_NEW_SIGNS.lamp} />
            <PaletteItem id="palette-cctv" kind="cctv" label="CCTV" icon={SAFETY_NEW_SIGNS.cctv} />
            <PaletteItem id="palette-speed" kind="speed_camera" label="Speed camera" icon={SAFETY_NEW_SIGNS.speed_camera} />
          </div>
          <small className="muted">Placed items can be dragged again on the map to move them.</small>
          {scenario.placements.length > 0 && (
            <ul className="new-stops">
              {scenario.placements.map((p, i) => {
                const d = districtIndexAt(p.lon, p.lat, data.districts);
                return (
                  <li key={`${p.lon},${p.lat},${i}`}>
                    <img src={SAFETY_NEW_SIGNS[p.kind]} alt="" width="24" height="24" />
                    <span className="plain-label">{KIND_LABELS[p.kind]} #{i + 1}<small>{d >= 0 ? data.districts[d].name : "—"}</small></span>
                    <button className="icon-btn" aria-label={`Remove ${KIND_LABELS[p.kind]} ${i + 1}`} onClick={() => dispatch({ type: "unplace", index: i })}>
                      <i className="fa-solid fa-xmark" />
                    </button>
                  </li>
                );
              })}
            </ul>
          )}
        </section>
      </aside>

      <div className="transport-main">
        <div className="map-toolbar">
          <label className="switch"><input type="checkbox" checked={showRegions} onChange={(e) => setShowRegions(e.target.checked)} /><span /> Districts</label>
          {Object.keys(show).map((k) => (
            <label key={k} className="switch small">
              <input type="checkbox" checked={show[k]} onChange={toggle(k)} /><span />
              <img src={SAFETY_SIGNS[k]} alt="" width="16" height="16" /> {KIND_LABELS[k]}s
            </label>
          ))}
          <RegionPicker districts={data.districts} selected={selected} onChange={setSelected} />
        </div>

        <div className="map-wrap">
          <DistrictMap
            districts={data.districts}
            selected={selected}
            showRegions={showRegions}
            onSelect={setSelected}
            label="Loading safety map"
            drop={{ id: "safety-map", accept: (k) => data.infra.includes(k), onDrop: (item, lon, lat) => dispatch({ type: "place", kind: item.kind, lon, lat }) }}
          >
            {(map) => <SafetyLayers map={map} data={data} show={show} placements={scenario.placements} dispatch={dispatch} />}
          </DistrictMap>
          {selected != null && (
            <DistrictCard
              district={data.districts[selected]}
              indicators={["b1", "b2"]}
              onClose={() => setSelected(null)}
              extra={[
                ["Fire stations", counts.byDistrict[selected].fire_station || 0],
                ["Police (dept · posts)", `${counts.byDistrict[selected].police_station || 0} · ${counts.byDistrict[selected].police_post || 0}`],
                ["Road deaths / year*", `≈ ${projection[selected].deaths.toFixed(0)}`],
                ...(projection[selected].b1 != null && projection[selected].b1After > projection[selected].b1 + 0.05
                  ? [["B1 with your plan", `${projection[selected].b1After.toFixed(0)}/100`]] : []),
              ]}
            />
          )}
          <div className="map-legend">
            {Object.entries(SAFETY_COLORS).map(([k, c]) => <span key={k}><i className="swatch" style={{ background: c }} /> {KIND_LABELS[k]}</span>)}
            <span><img src={SAFETY_NEW_SIGNS.lamp} alt="" width="14" height="14" /> New (drag to move)</span>
          </div>
        </div>

        <section className="t-card">
          <h4><i className="fa-solid fa-bullseye" /> Targets: street lighting &amp; road accidents</h4>
          <p className="muted small">
            District dataset targets — <strong>B1 street safety</strong>: 100 = lighting and cameras everywhere with minimal incidents;
            <strong> B2 road safety</strong>: 100 = minimal injury accidents. Below 40 counts as critical. Projections use the dataset's measures
            M10 (lighting &amp; cameras: +12 B1, +2 B2 for 12% of the budget) and M11 (safer roads: +12 B2 for 10%) — speed cameras count as M11-type spending.
          </p>
          <div className="table-scroll">
            <table className="district-table">
              <thead>
                <tr>
                  <th>District</th>
                  <th>New lamps · CCTV · speed cams</th>
                  <th>B1 street safety<br /><small>now → with plan (target 100)</small></th>
                  <th>B2 road safety<br /><small>now → with plan (target 100)</small></th>
                  <th>Road deaths*<br /><small>per 100 people · per year</small></th>
                </tr>
              </thead>
              <tbody>
                {data.districts.map((d, i) => {
                  const p = projection[i];
                  return (
                    <tr key={d.name}>
                      <th><i className="swatch" style={{ background: d.color }} /> {d.name}</th>
                      <td>
                        <div className="inline-inputs">
                          {data.infra.map((k) => (
                            <NumberField key={k} value={scenario.added[d.name]?.[k] || 0} decimals={0} ariaLabel={`New ${KIND_LABELS[k]}s in ${d.name}`}
                              onChange={(v) => dispatch({ type: "added", district: d.name, kind: k, value: v })} />
                          ))}
                        </div>
                        {(newInfra[i].lamp || newInfra[i].cctv || newInfra[i].speed_camera) ? (
                          <small className="muted">total {fmtInt(newInfra[i].lamp || 0)} · {fmtInt(newInfra[i].cctv || 0)} · {fmtInt(newInfra[i].speed_camera || 0)} incl. map</small>
                        ) : null}
                      </td>
                      <td>{p.b1 == null ? <span className="muted">no data</span> : <>{p.b1} → <strong className={p.b1After > p.b1 + 0.05 ? "up" : ""}>{p.b1After.toFixed(1)}</strong></>}</td>
                      <td>{p.b2 == null ? <span className="muted">no data</span> : <>{p.b2} → <strong className={p.b2After > p.b2 + 0.05 ? "up" : ""}>{p.b2After.toFixed(1)}</strong></>}</td>
                      <td>{(rate.value / 1000).toFixed(4)} · ≈ {p.deaths.toFixed(0)}</td>
                    </tr>
                  );
                })}
              </tbody>
            </table>
          </div>
          <div className="reference">
            <strong><i className="fa-solid fa-car-burst" /> Road safety — latest published figures</strong>
            <ul>
              {["road_deaths_rate", "road_deaths_total", "road_deaths_per_vehicles", "road_deaths_pedestrian_share", "road_crash_cost_gdp", "road_deaths_asia_pacific"].map((k) => refs[k] && (
                <li key={k}><span>{refs[k].label}</span><strong>{refs[k].value.toLocaleString("en-US")} {refs[k].unit}</strong></li>
              ))}
            </ul>
            <small>
              * <strong>No district-level accident data is published for Astana.</strong> The per-district figures apply Kazakhstan's national rate
              ({rate.value} deaths per 100,000 = {(rate.value / 1000).toFixed(4)} per 100 people) to each district's population. Source:{" "}
              <a href={rate.url} target="_blank" rel="noreferrer">{rate.source}</a> · data year {rate.data_year} · published {rate.published} · retrieved {rate.retrieved}.
            </small>
          </div>
        </section>

        <section className="t-card">
          <h4><i className="fa-solid fa-truck-medical" /> Add emergency &amp; city vehicles</h4>
          <p className="notice warn">
            <i className="fa-solid fa-gas-pump" /> Maintenance should include <strong>fuel (petrol/diesel) or charging for electric vehicles</strong>,
            not just repairs — adjust the maintenance cost below accordingly.
          </p>
          <div className="table-scroll">
            <table className="district-table vehicle-grid">
              <thead><tr><th>Vehicle</th>{data.districts.map((d) => <th key={d.name}><i className="swatch" style={{ background: d.color }} /> {d.name}</th>)}<th>Total</th></tr></thead>
              <tbody>
                {data.vehicles.map((k) => (
                  <tr key={k}>
                    <th><i className={VEHICLE_ICONS[k]} /> {VEHICLE_LABELS[k]}</th>
                    {names.map((n) => (
                      <td key={n}>
                        <NumberField value={scenario.vehicles[n]?.[k] || 0} decimals={0} ariaLabel={`${VEHICLE_LABELS[k]}s for ${n}`}
                          onChange={(v) => dispatch({ type: "vehicle", district: n, kind: k, value: v })} />
                      </td>
                    ))}
                    <td className="num">{fmtInt(qty[k])}</td>
                  </tr>
                ))}
              </tbody>
            </table>
          </div>
        </section>

        <section className="t-card">
          <h4><i className="fa-solid fa-coins" /> Costs</h4>
          <p className="muted small">Pre-filled planning estimates in tenge — edit them to match real quotes. Amounts in {plan.currency} or units; maintenance per month or per year.</p>
          <div className="table-scroll">
            <table className="cost-table">
              <thead><tr><th>Item</th><th>New</th><th>Purchase / setup <small>each</small></th><th>Maintenance <small>each, incl. fuel/charging</small></th><th>Setup total</th><th>Maintenance / year</th></tr></thead>
              <tbody>
                {[...data.infra, ...data.vehicles].map((k) => {
                  const c = costs[k];
                  const label = KIND_LABELS[k] || VEHICLE_LABELS[k];
                  const maintShown = show$(c.maintenance_period === "year" ? c.maintenance_kzt_month * 12 : c.maintenance_kzt_month, c.maintenance_measure);
                  return (
                    <tr key={k}>
                      <th>{SAFETY_SIGNS[k] ? <img src={SAFETY_SIGNS[k]} alt="" width="18" height="18" /> : <i className={VEHICLE_ICONS[k]} />} {label}</th>
                      <td className="num">{fmtInt(qty[k])}</td>
                      <td>
                        <div className="cost-input">
                          <NumberField value={show$(c.setup_kzt, c.setup_measure)} decimals={dec(c.setup_measure)} ariaLabel={`${label} purchase cost`}
                            onChange={(v) => dispatch({ type: "cost", asset: k, patch: { setup_kzt: toKzt(v, c.setup_measure, plan, rates) } })} />
                          <MeasureSelect value={c.setup_measure} currency={plan.currency} label={`${label} purchase measure`}
                            onChange={(m) => dispatch({ type: "cost", asset: k, patch: { setup_measure: m } })} />
                        </div>
                      </td>
                      <td>
                        <div className="cost-input">
                          <NumberField value={maintShown} decimals={dec(c.maintenance_measure)} ariaLabel={`${label} maintenance cost`}
                            onChange={(v) => {
                              const kzt = toKzt(v, c.maintenance_measure, plan, rates);
                              dispatch({ type: "cost", asset: k, patch: { maintenance_kzt_month: c.maintenance_period === "year" ? kzt / 12 : kzt } });
                            }} />
                          <MeasureSelect value={c.maintenance_measure} currency={plan.currency} label={`${label} maintenance measure`}
                            onChange={(m) => dispatch({ type: "cost", asset: k, patch: { maintenance_measure: m } })} />
                          <select className="mini-select" aria-label={`${label} maintenance period`} value={c.maintenance_period}
                            onChange={(e) => dispatch({ type: "cost", asset: k, patch: { maintenance_period: e.target.value } })}>
                            <option value="month">/ month</option>
                            <option value="year">/ year</option>
                          </select>
                        </div>
                      </td>
                      <td className="num">{inPlan((qty[k] || 0) * c.setup_kzt)}</td>
                      <td className="num">{inPlan((qty[k] || 0) * c.maintenance_kzt_month * 12)}</td>
                    </tr>
                  );
                })}
              </tbody>
              <tfoot>
                <tr><th colSpan={4}>Purchase / setup</th><td className="num" colSpan={2}>{inPlan(setupKzt)}</td></tr>
                <tr><th colSpan={4}>Maintenance per year (incl. fuel / charging)</th><td className="num" colSpan={2}>{inPlan(maintYear)}</td></tr>
                <tr className="grand"><th colSpan={4}>First-year total</th><td className="num" colSpan={2}>{inPlan(firstYear)}</td></tr>
              </tfoot>
            </table>
          </div>
        </section>

        <footer className="sources">
          <strong>Sources</strong>
          <ul>
            {data.sources.map((s) => <li key={s.label}>{s.label} — {s.url ? <a href={s.url} target="_blank" rel="noreferrer">{s.cite}</a> : s.cite}</li>)}
          </ul>
        </footer>
      </div>
    </div>
  );
}
