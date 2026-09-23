// Floating card for the selected district: population (qazatlas) + dataset indicators.
export const INDICATOR_LABELS = {
  t1: "Congestion relief (T1)", t2: "Transit access (T2)", e1: "Green space (E1)", e2: "Air quality (E2)",
  s1: "Schools & kindergartens (S1)", s2: "Clinics & primary care (S2)", b1: "Street safety (B1)",
  b2: "Road safety (B2)", c1: "Utility reliability (C1)", c2: "Request resolution (C2)",
};

export default function DistrictCard({ district: d, indicators = [], extra = [], onClose }) {
  const fmt = (n) => Math.round(n).toLocaleString("en-US");
  const values = indicators.map((k) => [k, d.indicators?.[k]]).filter(([, v]) => v != null);
  return (
    <div className="region-card" style={{ "--region": d.color }} aria-live="polite">
      <button className="icon-btn close" aria-label="Show all of Astana" onClick={onClose}><i className="fa-solid fa-xmark" /></button>
      <span className="region-kk">{d.name_kk} ауданы</span>
      <h4>{d.name} district</h4>
      <div className="region-pop">
        <strong>{fmt(d.population)}</strong>
        <span>residents · {d.population_share}% of Astana</span>
      </div>
      {d.population_change != null && (
        <span className={`region-change ${d.population_change >= 0 ? "up" : "down"}`}>
          <i className={`fa-solid ${d.population_change >= 0 ? "fa-arrow-trend-up" : "fa-arrow-trend-down"}`} />
          {d.population_change > 0 ? "+" : ""}{d.population_change}% in a year
        </span>
      )}
      <dl>
        <div><dt>Area</dt><dd>{fmt(d.area_km2)} km²</dd></div>
        <div><dt>Density</dt><dd>{fmt(d.population / d.area_km2)} / km²</dd></div>
        {extra.map(([label, value]) => <div key={label}><dt>{label}</dt><dd>{value}</dd></div>)}
        {values.map(([k, v]) => (
          <div key={k}><dt>{INDICATOR_LABELS[k]}</dt><dd className={v < 40 ? "crit" : ""}>{v}/100</dd></div>
        ))}
      </dl>
      {d.profile && <p className="region-profile">{d.profile}</p>}
      <small>Population: qazatlas.kz, 1 July 2026{values.length ? " · indicators: district dataset (100 = target, <40 = critical)" : ""}</small>
    </div>
  );
}
