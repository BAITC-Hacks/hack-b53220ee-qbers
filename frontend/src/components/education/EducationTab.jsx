import { useEffect, useMemo, useReducer, useRef, useState } from "react";
import { useProgress } from "../../hooks/useProgress";
import { api } from "../../lib/api";
import { createDraggableMarker } from "../../lib/dragMarker";
import { HORIZONS, KINDERGARTEN_AGES, REF_YEAR, SCHOOL_AGES, birthsFn, calibrateUplift, childrenIn, readiness, readinessLabel } from "../../lib/education";
import { districtIndexAt } from "../../lib/geo";
import { formatAmount, fromKzt, kztPerUnit, rateOf, toKzt } from "../../lib/money";
import { EDU_COLORS, EDU_NEW_SIGNS, EDU_SIGNS } from "../../lib/signs";
import { PaletteItem } from "../dnd/DndProvider";
import DistrictCard from "../districts/DistrictCard";
import DistrictMap from "../districts/DistrictMap";
import RegionPicker from "../districts/RegionPicker";
import NumberField from "../NumberField";
import { LoadingOverlay, ProgressBar } from "../ProgressBar";
import { MeasureSelect } from "../transport/CostTable";

const NOW = 2026;
const fmtInt = (n) => Math.round(n).toLocaleString("en-US");
const esc = (s) => String(s ?? "").replace(/[&<>"']/g, (c) => `&#${c.charCodeAt(0)};`);
const LABEL = { school: "School", kindergarten: "Kindergarten" };
const signOf = ([kind, , , , , , isPublic]) => (kind === "school" ? "school" : isPublic ? "kindergarten_state" : "kindergarten_private");

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
    case "capacity":
      return next({ capacity: { ...s.capacity, [a.kind]: Math.max(1, Math.round(a.value) || 1) } });
    case "staff":
      return next({ staff: { ...s.staff, [a.kind]: { ...s.staff[a.kind], [a.role]: Math.max(0, Math.round(a.value) || 0) } } });
    case "build":
      return next({ costs: { ...s.costs, build: { ...s.costs.build, ...a.patch } } });
    case "pay":
      return next({ costs: { ...s.costs, pay: { ...s.costs.pay, ...a.patch } } });
    case "projection":
      return next({ projection: { ...s.projection, ...a.patch } });
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

function Readiness({ pct }) {
  return <span className={`readiness ${pct < -0.5 ? "under" : pct > 0.5 ? "over" : "ok"}`}>{pct > 0 ? "+" : ""}{pct.toFixed(1)}%</span>;
}

/** School & kindergarten markers + draggable new buildings. */
function EducationLayers({ map, data, show, placements, dispatch }) {
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
    const visible = data.places.filter((p) => show[signOf(p)]);
    setLoading({ done: false, floor: 10 });
    (async () => {
      for (let i = 0; i < visible.length; i++) {
        const p = visible[i];
        const [kind, lon, lat, d, name, subtype, , address] = p;
        const size = kind === "school" ? 22 : 16;
        const mk = new window.mapgl.Marker(map, { coordinates: [lon, lat], icon: EDU_SIGNS[signOf(p)], size: [size, size], anchor: [size / 2, size / 2], zIndex: kind === "school" ? 25 : 15 });
        mk.on("click", () => openPopup([lon, lat], `<strong>${esc(name)}</strong><span>${esc(subtype)} · ${esc(data.districts[d].name)}</span>${address ? `<span>${esc(address)}</span>` : ""}<span>Source: 2GIS</span>`));
        markers.current.push(mk);
        if (i % 120 === 119) {
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
        coordinates: [p.lon, p.lat], icon: EDU_NEW_SIGNS[p.kind], size: 32, zIndex: 40,
        title: `New ${LABEL[p.kind].toLowerCase()} — drag to move`,
        onMoveEnd: ([lon, lat]) => dispatch({ type: "move", index: i, lon, lat }),
        onClick: () => openPopup([p.lon, p.lat], `<strong>New ${LABEL[p.kind].toLowerCase()} #${i + 1}</strong><span>Drag it to move · remove it in the sidebar.</span>`),
      })
    );
    return () => placed.current.forEach((m) => m.destroy());
  }, [map, placements]); // eslint-disable-line react-hooks/exhaustive-deps
  useEffect(() => () => markers.current.forEach((m) => m.destroy()), []);
  return loading.done ? null : <LoadingOverlay done={false} floor={loading.floor} label="Placing schools & kindergartens" className="is-compact map-layer-loader" />;
}

export default function EducationTab({ plan, rates }) {
  const [data, setData] = useState(null);
  const [scenario, dispatch] = useReducer(reducer, null);
  const [loaded, setLoaded] = useState({});
  const [loadError, setLoadError] = useState(null);
  const [save, setSave] = useState({ state: "idle" });
  const [selected, setSelected] = useState(null);
  const [showRegions, setShowRegions] = useState(true);
  const [show, setShow] = useState({ school: true, kindergarten_state: true, kindergarten_private: true });
  const saveTimer = useRef(null);

  useEffect(() => {
    const done = (k) => () => setLoaded((l) => ({ ...l, [k]: true }));
    api("education/").then(setData).catch((e) => setLoadError(e.message)).finally(done("data"));
    api("education/scenario/").then((s) => dispatch({ type: "load", scenario: s })).catch((e) => setLoadError(e.message)).finally(done("scenario"));
  }, []);

  useEffect(() => {
    if (!scenario?.dirty) return undefined;
    clearTimeout(saveTimer.current);
    saveTimer.current = setTimeout(() => {
      setSave({ state: "saving" });
      api("education/scenario/", { method: "PUT", body: toApi(scenario) })
        .then((s) => setSave({ state: "saved", at: new Date(s.updated_at).toLocaleTimeString("en-GB", { hour: "2-digit", minute: "2-digit" }) }))
        .catch((e) => setSave({ state: "error", message: e.message }));
    }, 800);
    return () => clearTimeout(saveTimer.current);
  }, [scenario]);

  const mapCounts = useMemo(() => {
    if (!data) return null;
    const byDistrict = data.districts.map(() => ({ school: 0, kindergarten_state: 0, kindergarten_private: 0 }));
    const total = { school: 0, kindergarten_state: 0, kindergarten_private: 0 };
    for (const p of data.places) {
      const s = signOf(p);
      byDistrict[p[3]][s] += 1;
      total[s] += 1;
    }
    return { byDistrict, total };
  }, [data]);

  if (Object.keys(loaded).length < 2 || !data || !scenario) {
    return (
      <div className="transport transport-loading">
        {loadError ? <div className="banner bad"><i className="fa-solid fa-triangle-exclamation" /> {loadError}</div>
          : <LoadingOverlay done={false} floor={Object.keys(loaded).length * 45} label="Loading schools & kindergartens" />}
      </div>
    );
  }

  const refs = data.references;
  const births = Object.fromEntries(Object.entries(data.births).map(([y, b]) => [Number(y), b]));

  // ---- cohort model ----
  const pupils = refs.school_pupils.value;
  const kCalibrated = calibrateUplift(births, pupils);
  const k = scenario.projection.migration_uplift_pct == null ? kCalibrated : scenario.projection.migration_uplift_pct / 100 / 16;
  const birthsAt = birthsFn(births, scenario.projection.births_change_pct);
  const schoolNow = childrenIn(REF_YEAR, SCHOOL_AGES, birthsAt, k);
  const kgNow = childrenIn(NOW, KINDERGARTEN_AGES, birthsAt, k);

  // ---- new buildings (map + per-district) ----
  const names = data.districts.map((d) => d.name);
  const newByDistrict = names.map((n) => ({ ...scenario.added[n] }));
  for (const p of scenario.placements) {
    const d = districtIndexAt(p.lon, p.lat, data.districts);
    if (d >= 0) newByDistrict[d][p.kind] = (newByDistrict[d][p.kind] || 0) + 1;
  }
  const nNew = {
    school: newByDistrict.reduce((a, x) => a + (x.school || 0), 0),
    kindergarten: newByDistrict.reduce((a, x) => a + (x.kindergarten || 0), 0),
  };
  const schoolPlaces = refs.school_capacity.value;
  const kgPlaces = refs.kg_capacity.value;
  const schoolPlacesAfter = schoolPlaces + nNew.school * scenario.capacity.school;
  const kgPlacesAfter = kgPlaces + nNew.kindergarten * scenario.capacity.kindergarten;

  const rows = HORIZONS.map((h) => {
    const year = NOW + h;
    const school = childrenIn(year, SCHOOL_AGES, birthsAt, k);
    const kg = childrenIn(year, KINDERGARTEN_AGES, birthsAt, k);
    return { h, year, school, kg, schoolNow: readiness(schoolPlaces, school), schoolAfter: readiness(schoolPlacesAfter, school),
      kgNowR: readiness(kgPlaces, kg), kgAfter: readiness(kgPlacesAfter, kg) };
  });

  // ---- districts: children split by 2024 births; capacity by buildings on the map ----
  const birthTotal = data.districts.reduce((a, d) => a + (d.births_2024 || 0), 0);
  const perSchool = schoolPlaces / mapCounts.total.school;
  const perStateKg = refs.kg_capacity_state.value / mapCounts.total.kindergarten_state;
  const perPrivateKg = refs.kg_capacity_private.value / mapCounts.total.kindergarten_private;
  const districtRows = data.districts.map((d, i) => {
    const share = (d.births_2024 || 0) / birthTotal;
    const c = mapCounts.byDistrict[i];
    const schoolCap = c.school * perSchool + (newByDistrict[i].school || 0) * scenario.capacity.school;
    const kgCap = c.kindergarten_state * perStateKg + c.kindergarten_private * perPrivateKg + (newByDistrict[i].kindergarten || 0) * scenario.capacity.kindergarten;
    const sKids = schoolNow * share;
    const kKids = kgNow * share;
    return { share, sKids, kKids, schoolCap, kgCap, sR: readiness(schoolCap, sKids), kR: readiness(kgCap, kKids) };
  });

  // ---- staff & costs (tenge), shown in the plan's measure ----
  const { staff, costs } = scenario;
  const teachers = nNew.school * staff.school.teachers;
  const kgTeachers = nNew.kindergarten * staff.kindergarten.teachers;
  const workers = nNew.school * staff.school.workers + nNew.kindergarten * staff.kindergarten.workers;
  const buildKzt = nNew.school * costs.build.school + nNew.kindergarten * costs.build.kindergarten;
  const payMonth = teachers * costs.pay.teacher + kgTeachers * costs.pay.kg_teacher + workers * costs.pay.worker;
  const firstYear = buildKzt + payMonth * 12;
  const mode = plan.mode;
  const budgetValue = plan[mode].allocations.social;
  const budgetKzt = mode === "money" ? budgetValue / rateOf(plan.currency, rates) : budgetValue * kztPerUnit(plan, rates);
  const used = budgetKzt > 0 ? (firstYear / budgetKzt) * 100 : 0;
  const inPlan = (kzt) => formatAmount(fromKzt(kzt, mode, plan, rates), { mode, currency: plan.currency });
  const inMeasure = (kzt, measure) => formatAmount(fromKzt(kzt, measure, plan, rates), { mode: measure, currency: plan.currency });
  const payPeriod = costs.pay.period === "year" ? 12 : 1;
  const show$ = (kzt, measure) => fromKzt(kzt, measure, plan, rates);
  const dec = (m) => (m === "units" ? 2 : 0);

  const schoolR = readiness(schoolPlaces, pupils);
  const kgR = readiness(kgPlaces, kgNow);
  const toggle = (key) => (e) => setShow((s) => ({ ...s, [key]: e.target.checked }));

  return (
    <div className="transport education">
      <aside className="transport-side">
        <section className="t-card t-budget">
          <header><span className="area-caption">Social services budget</span><SaveBadge save={save} /></header>
          <strong className="area-amount">{formatAmount(budgetValue, { mode, currency: plan.currency })}</strong>
          <div className="share">
            <div className={`share-bar ${used > 100 ? "over" : ""}`}><div style={{ width: `${Math.min(100, used)}%` }} /></div>
            <span>First-year cost <strong>{inPlan(firstYear)}</strong> · {used.toFixed(1)}% used</span>
          </div>
          {used > 100
            ? <p className="t-warn bad"><i className="fa-solid fa-circle-exclamation" /> Over the social-services budget by {inPlan(firstYear - budgetKzt)}</p>
            : <p className="t-warn ok"><i className="fa-solid fa-piggy-bank" /> {inPlan(budgetKzt - firstYear)} left this year</p>}
        </section>

        <section className="t-card">
          <h4><i className="fa-solid fa-children" /> Children today</h4>
          <div className="count-grid">
            <div className="count-box"><i className="fa-solid fa-person-running edu-i" /><div>
              <span className="count-label">School age ({SCHOOL_AGES[0]}–{SCHOOL_AGES[1]})</span><strong>{fmtInt(pupils)}</strong><small>pupils, 2025/26</small></div></div>
            <div className="count-box"><i className="fa-solid fa-baby edu-i" /><div>
              <span className="count-label">Toddlers ({KINDERGARTEN_AGES[0]}–{KINDERGARTEN_AGES[1]})</span><strong>≈ {fmtInt(kgNow)}</strong><small>estimate from births</small></div></div>
            <div className="count-box"><img src={EDU_SIGNS.school} alt="" width="26" height="26" /><div>
              <span className="count-label">Schools</span><strong>{fmtInt(refs.schools_total.value)}</strong><small>{mapCounts.total.school} on the map (2GIS)</small></div></div>
            <div className="count-box"><img src={EDU_SIGNS.kindergarten_state} alt="" width="26" height="26" /><div>
              <span className="count-label">Kindergartens</span><strong>{fmtInt(refs.kg_orgs.value)}</strong>
              <small>{mapCounts.total.kindergarten_state} state + {mapCounts.total.kindergarten_private} private on the map</small></div></div>
          </div>

          <h4><i className="fa-solid fa-scale-unbalanced" /> Can today's places fit them?</h4>
          <div className="fit">
            <div className={`fit-row ${schoolR < 0 ? "under" : "over"}`}>
              <span>School places</span><strong>{fmtInt(schoolPlaces)}</strong>
              <span>for {fmtInt(pupils)} pupils</span><Readiness pct={schoolR} />
              <small>{schoolR < 0 ? `No — ${fmtInt(-(schoolPlaces - pupils))} places short (${readinessLabel(schoolR)})` : "Yes"}</small>
            </div>
            <div className={`fit-row ${kgR < 0 ? "under" : "over"}`}>
              <span>Kindergarten places</span><strong>{fmtInt(kgPlaces)}</strong>
              <span>for ≈ {fmtInt(kgNow)} children</span><Readiness pct={kgR} />
              <small>{kgR < 0 ? `No — ≈ ${fmtInt(kgNow - kgPlaces)} short (${readinessLabel(kgR)}). Waiting list: ${fmtInt(refs.kg_queue.value)}. Official coverage ${refs.kg_coverage.value}% also counts pre-school classes and mini-centres.` : "Yes"}</small>
            </div>
          </div>
        </section>

        <section className="t-card">
          <h4><i className="fa-solid fa-hand-pointer" /> Build — drag onto the map</h4>
          <div className="palette">
            <PaletteItem id="palette-school" kind="school" label="School" icon={EDU_NEW_SIGNS.school} />
            <PaletteItem id="palette-kindergarten" kind="kindergarten" label="Kindergarten" icon={EDU_NEW_SIGNS.kindergarten} />
          </div>
          <small className="muted">
            Each new school adds {fmtInt(scenario.capacity.school)} places, {staff.school.teachers} teachers and {staff.school.workers} support staff;
            each kindergarten {fmtInt(scenario.capacity.kindergarten)} places, {staff.kindergarten.teachers} teachers and {staff.kindergarten.workers} support staff.
            Drag placed buildings to move them.
          </small>
          {scenario.placements.length > 0 && (
            <ul className="new-stops">
              {scenario.placements.map((p, i) => {
                const d = districtIndexAt(p.lon, p.lat, data.districts);
                return (
                  <li key={`${p.lon},${p.lat},${i}`}>
                    <img src={EDU_NEW_SIGNS[p.kind]} alt="" width="24" height="24" />
                    <span className="plain-label">{LABEL[p.kind]} #{i + 1}<small>{d >= 0 ? data.districts[d].name : "—"}</small></span>
                    <button className="icon-btn" aria-label={`Remove ${LABEL[p.kind]} ${i + 1}`} onClick={() => dispatch({ type: "unplace", index: i })}><i className="fa-solid fa-xmark" /></button>
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
          <label className="switch small"><input type="checkbox" checked={show.school} onChange={toggle("school")} /><span /><img src={EDU_SIGNS.school} alt="" width="16" height="16" /> Schools</label>
          <label className="switch small"><input type="checkbox" checked={show.kindergarten_state} onChange={toggle("kindergarten_state")} /><span /><img src={EDU_SIGNS.kindergarten_state} alt="" width="16" height="16" /> State kindergartens</label>
          <label className="switch small"><input type="checkbox" checked={show.kindergarten_private} onChange={toggle("kindergarten_private")} /><span /><img src={EDU_SIGNS.kindergarten_private} alt="" width="16" height="16" /> Private kindergartens</label>
          <RegionPicker districts={data.districts} selected={selected} onChange={setSelected} />
        </div>

        <div className="map-wrap">
          <DistrictMap
            districts={data.districts}
            selected={selected}
            showRegions={showRegions}
            onSelect={setSelected}
            label="Loading schools map"
            drop={{ id: "education-map", accept: (kind) => kind === "school" || kind === "kindergarten", onDrop: (item, lon, lat) => dispatch({ type: "place", kind: item.kind, lon, lat }) }}
          >
            {(map) => <EducationLayers map={map} data={data} show={show} placements={scenario.placements} dispatch={dispatch} />}
          </DistrictMap>
          {selected != null && (
            <DistrictCard
              district={data.districts[selected]}
              indicators={["s1", "s2"]}
              onClose={() => setSelected(null)}
              extra={[
                ["Births (2024)", fmtInt(data.districts[selected].births_2024 || 0)],
                ["Schools · kindergartens", `${mapCounts.byDistrict[selected].school} · ${mapCounts.byDistrict[selected].kindergarten_state + mapCounts.byDistrict[selected].kindergarten_private}`],
                ["School places vs children", <Readiness key="s" pct={districtRows[selected].sR} />],
                ["Kindergarten places vs children", <Readiness key="k" pct={districtRows[selected].kR} />],
              ]}
            />
          )}
          <div className="map-legend">
            <span><img src={EDU_SIGNS.school} alt="" width="14" height="14" /> School / gymnasium / lyceum</span>
            <span><img src={EDU_SIGNS.kindergarten_state} alt="" width="14" height="14" /> State kindergarten</span>
            <span><img src={EDU_SIGNS.kindergarten_private} alt="" width="14" height="14" /> Private kindergarten</span>
            <span><img src={EDU_NEW_SIGNS.school} alt="" width="16" height="16" /> New (drag to move)</span>
          </div>
        </div>

        <section className="t-card">
          <header className="coverage-head">
            <h4><i className="fa-solid fa-chart-line" /> Projected children — 5, 10 and 15 years</h4>
          </header>
          <div className="coverage-inputs">
            <div className="field"><span>Births change per year</span>
              <NumberField value={scenario.projection.births_change_pct} decimals={1} suffix="% / yr" ariaLabel="Births change per year"
                onChange={(v) => v >= -20 && v <= 20 && dispatch({ type: "projection", patch: { births_change_pct: v } })} /></div>
            <div className="field"><span>Migration uplift by age 16</span>
              <NumberField value={+(k * 16 * 100).toFixed(1)} decimals={1} suffix="%" ariaLabel="Migration uplift"
                onChange={(v) => v >= 0 && v <= 100 && dispatch({ type: "projection", patch: { migration_uplift_pct: v } })} /></div>
            {scenario.projection.migration_uplift_pct != null && (
              <button className="link-btn" onClick={() => dispatch({ type: "projection", patch: { migration_uplift_pct: null } })}>
                Reset to calibrated {(kCalibrated * 16 * 100).toFixed(1)}%
              </button>
            )}
          </div>
          <small className="muted">
            Children aged a in year Y ≈ births in (Y − a) × a migration uplift that grows with age, calibrated so today's 6–16-year-olds match the
            {" "}{fmtInt(pupils)} pupils. Future births start from the {Math.max(...Object.keys(births).map(Number)) - 2}–{Math.max(...Object.keys(births).map(Number))} average
            ({fmtInt(birthsAt(NOW))} a year).
          </small>
          <div className="table-scroll">
            <table className="district-table projection">
              <thead>
                <tr>
                  <th>Year</th>
                  <th>School-age {SCHOOL_AGES[0]}–{SCHOOL_AGES[1]}</th>
                  <th>School places<br /><small>today → with new schools</small></th>
                  <th>Readiness<br /><small>today → with new</small></th>
                  <th>Toddlers {KINDERGARTEN_AGES[0]}–{KINDERGARTEN_AGES[1]}</th>
                  <th>Kindergarten places<br /><small>today → with new</small></th>
                  <th>Readiness<br /><small>today → with new</small></th>
                </tr>
              </thead>
              <tbody>
                {rows.map((r) => (
                  <tr key={r.year}>
                    <th>{r.year}{r.h ? <small> (+{r.h} yrs)</small> : <small> (now)</small>}</th>
                    <td>{fmtInt(r.h ? r.school : pupils)}</td>
                    <td>{fmtInt(schoolPlaces)}{nNew.school ? <> → <strong>{fmtInt(schoolPlacesAfter)}</strong></> : ""}</td>
                    <td><Readiness pct={r.h ? r.schoolNow : schoolR} />{nNew.school ? <> → <Readiness pct={r.h ? r.schoolAfter : readiness(schoolPlacesAfter, pupils)} /></> : ""}</td>
                    <td>{fmtInt(r.kg)}</td>
                    <td>{fmtInt(kgPlaces)}{nNew.kindergarten ? <> → <strong>{fmtInt(kgPlacesAfter)}</strong></> : ""}</td>
                    <td><Readiness pct={r.kgNowR} />{nNew.kindergarten ? <> → <Readiness pct={r.kgAfter} /></> : ""}</td>
                  </tr>
                ))}
              </tbody>
            </table>
          </div>
          <p className="notice">
            <i className="fa-solid fa-circle-info" />
            <span>
              Astana is <strong>{readinessLabel(schoolR)}</strong> for schools today and <strong>{readinessLabel(kgR)}</strong> for kindergartens.
              In 15 years ({rows[3].year}) today's places would leave schools <strong>{readinessLabel(rows[3].schoolNow)}</strong> and kindergartens{" "}
              <strong>{readinessLabel(rows[3].kgNowR)}</strong>{nNew.school + nNew.kindergarten ? <> — with your new buildings: schools <strong>{readinessLabel(rows[3].schoolAfter)}</strong>, kindergartens <strong>{readinessLabel(rows[3].kgAfter)}</strong></> : ""}.
            </span>
          </p>
        </section>

        <section className="t-card">
          <h4><i className="fa-solid fa-map" /> By district</h4>
          <div className="table-scroll">
            <table className="district-table">
              <thead>
                <tr>
                  <th>District</th><th>Births 2024</th>
                  <th>School-age<br /><small>estimate</small></th><th>School places<br /><small>estimate</small></th><th>Readiness</th>
                  <th>Toddlers<br /><small>estimate</small></th><th>Kindergarten places<br /><small>estimate</small></th><th>Readiness</th>
                  <th>Add schools · kindergartens</th>
                </tr>
              </thead>
              <tbody>
                {data.districts.map((d, i) => {
                  const r = districtRows[i];
                  return (
                    <tr key={d.name} className={selected === i ? "is-selected" : ""}>
                      <th><i className="swatch" style={{ background: d.color }} /> {d.name}</th>
                      <td>{fmtInt(d.births_2024 || 0)}</td>
                      <td>{fmtInt(r.sKids)}</td><td>{fmtInt(r.schoolCap)}</td><td><Readiness pct={r.sR} /></td>
                      <td>{fmtInt(r.kKids)}</td><td>{fmtInt(r.kgCap)}</td><td><Readiness pct={r.kR} /></td>
                      <td>
                        <div className="inline-inputs two">
                          <NumberField value={scenario.added[d.name]?.school || 0} decimals={0} ariaLabel={`New schools in ${d.name}`}
                            onChange={(v) => dispatch({ type: "added", district: d.name, kind: "school", value: v })} />
                          <NumberField value={scenario.added[d.name]?.kindergarten || 0} decimals={0} ariaLabel={`New kindergartens in ${d.name}`}
                            onChange={(v) => dispatch({ type: "added", district: d.name, kind: "kindergarten", value: v })} />
                        </div>
                      </td>
                    </tr>
                  );
                })}
              </tbody>
            </table>
          </div>
          <small className="muted">
            District estimates: children split by each district's share of 2024 births (Saraishyq shares Almaty's figure by population);
            places split by the buildings on the map (≈{fmtInt(perSchool)} per school, ≈{fmtInt(perStateKg)} per state and ≈{fmtInt(perPrivateKg)} per private kindergarten,
            matching the city totals). New buildings dropped on the map count towards their district.
          </small>
        </section>

        <section className="t-card">
          <h4><i className="fa-solid fa-coins" /> Build, staff &amp; pay</h4>
          <p className="muted small">
            Pre-filled from published figures (sources below) — edit any of them. Staff pay is the maintenance cost. Show amounts in {plan.currency} or units (tokens), pay per month or per year.
          </p>
          <div className="table-scroll">
            <table className="cost-table">
              <thead><tr><th>Per new building</th><th>Places</th><th>Teachers</th><th>Support staff</th><th>Build cost <small>each</small></th><th>New</th><th>Build total</th></tr></thead>
              <tbody>
                {["school", "kindergarten"].map((kind) => (
                  <tr key={kind}>
                    <th><img src={kind === "school" ? EDU_SIGNS.school : EDU_SIGNS.kindergarten_state} alt="" width="18" height="18" /> {LABEL[kind]}</th>
                    <td><NumberField value={scenario.capacity[kind]} decimals={0} ariaLabel={`${LABEL[kind]} places`} onChange={(v) => dispatch({ type: "capacity", kind, value: v })} /></td>
                    <td><NumberField value={staff[kind].teachers} decimals={0} ariaLabel={`${LABEL[kind]} teachers`} onChange={(v) => dispatch({ type: "staff", kind, role: "teachers", value: v })} /></td>
                    <td><NumberField value={staff[kind].workers} decimals={0} ariaLabel={`${LABEL[kind]} support staff`} onChange={(v) => dispatch({ type: "staff", kind, role: "workers", value: v })} /></td>
                    <td>
                      <div className="cost-input">
                        <NumberField value={show$(costs.build[kind], costs.build.measure)} decimals={dec(costs.build.measure)} ariaLabel={`${LABEL[kind]} build cost`}
                          onChange={(v) => dispatch({ type: "build", patch: { [kind]: toKzt(v, costs.build.measure, plan, rates) } })} />
                        <MeasureSelect value={costs.build.measure} currency={plan.currency} label="Build cost measure" onChange={(m) => dispatch({ type: "build", patch: { measure: m } })} />
                      </div>
                    </td>
                    <td className="num">{fmtInt(nNew[kind])}</td>
                    <td className="num">{inMeasure(nNew[kind] * costs.build[kind], costs.build.measure)}</td>
                  </tr>
                ))}
              </tbody>
            </table>
          </div>

          <div className="table-scroll">
            <table className="cost-table">
              <thead>
                <tr>
                  <th>Staff (maintenance)</th>
                  <th>Pay per person <small>
                    <select className="mini-select" aria-label="Pay period" value={costs.pay.period} onChange={(e) => dispatch({ type: "pay", patch: { period: e.target.value } })}>
                      <option value="month">/ month</option><option value="year">/ year</option>
                    </select>{" "}
                    <MeasureSelect value={costs.pay.measure} currency={plan.currency} label="Pay measure" onChange={(m) => dispatch({ type: "pay", patch: { measure: m } })} />
                  </small></th>
                  <th>New staff</th>
                  <th>Pay total {costs.pay.period === "year" ? "/ year" : "/ month"}</th>
                  <th>Source</th>
                </tr>
              </thead>
              <tbody>
                {[
                  ["teacher", "School teachers", teachers, refs.pay_teacher],
                  ["kg_teacher", "Kindergarten teachers", kgTeachers, refs.pay_kg_teacher],
                  ["worker", "Support staff (cleaners, guards, cooks, maintenance)", workers, null],
                ].map(([key, label, count, ref]) => (
                  <tr key={key}>
                    <th>{label}</th>
                    <td>
                      <NumberField value={show$(costs.pay[key] * payPeriod, costs.pay.measure)} decimals={dec(costs.pay.measure)} ariaLabel={`${label} pay`}
                        onChange={(v) => dispatch({ type: "pay", patch: { [key]: toKzt(v, costs.pay.measure, plan, rates) / payPeriod } })} />
                    </td>
                    <td className="num">{fmtInt(count)}</td>
                    <td className="num">{inMeasure(count * costs.pay[key] * payPeriod, costs.pay.measure)}</td>
                    <td className="src">
                      {ref ? <a href={ref.url} target="_blank" rel="noreferrer">{fmtInt(ref.value)} {ref.unit} · {ref.data_year}</a>
                        : <span>Estimate — no official figure. Minimum wage {fmtInt(refs.min_wage.value)} ₸ ({refs.min_wage.data_year});
                          education-sector average {fmtInt(refs.pay_education_avg.value)} ₸ ({refs.pay_education_avg.data_year}).</span>}
                    </td>
                  </tr>
                ))}
              </tbody>
              <tfoot>
                <tr><th colSpan={3}>Build (one-off)</th><td className="num" colSpan={2}>{inPlan(buildKzt)}</td></tr>
                <tr><th colSpan={3}>Staff pay per year (maintenance)</th><td className="num" colSpan={2}>{inPlan(payMonth * 12)}</td></tr>
                <tr className="grand"><th colSpan={3}>First-year total</th><td className="num" colSpan={2}>{inPlan(firstYear)}</td></tr>
              </tfoot>
            </table>
          </div>
        </section>

        <footer className="sources">
          <strong>Sources</strong>
          <ul>
            {data.sources.map((s) => <li key={s.label}>{s.label} — {s.url ? <a href={s.url} target="_blank" rel="noreferrer">{s.cite}</a> : s.cite}</li>)}
            <li>Births {data.births_estimated.join(", ")} summed from monthly figures. Figures retrieved {refs.school_pupils.retrieved}.</li>
          </ul>
        </footer>
      </div>
    </div>
  );
}
