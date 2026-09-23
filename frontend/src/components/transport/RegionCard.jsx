const fmt = (n) => n.toLocaleString("en-US");

export default function RegionCard({ district: d, index, data, result, added, onClose }) {
  const stops = data.bus_stops.filter((s) => s[2] === index).length;
  const stations = data.rail_stations.filter((s) => s.district === index).length;
  const r = result?.byDistrict[index];
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
        <div><dt>Density</dt><dd>{fmt(Math.round(d.population / d.area_km2))} / km²</dd></div>
        <div><dt>Bus stops</dt><dd>{fmt(stops)}{added.bus ? ` +${added.bus}` : ""}</dd></div>
        <div><dt>Stations</dt><dd>{stations}{added.rail ? ` +${added.rail}` : ""}</dd></div>
        {r && <div><dt>Near a bus stop</dt><dd>{r.busOld.toFixed(0)}% → {r.busNew.toFixed(0)}%</dd></div>}
        {d.t2 != null && <div><dt>Transit access (T2)</dt><dd>{d.t2}/100</dd></div>}
        {d.t1 != null && <div><dt>Congestion relief (T1)</dt><dd>{d.t1}/100</dd></div>}
      </dl>
      <small>Population: qazatlas.kz, 1 July 2026{d.t2 != null ? " · T1/T2: district dataset" : ""}</small>
    </div>
  );
}
