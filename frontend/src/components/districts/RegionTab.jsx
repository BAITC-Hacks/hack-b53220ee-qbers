import { useEffect, useState } from "react";
import { api } from "../../lib/api";
import { LoadingOverlay } from "../ProgressBar";
import DistrictCard, { INDICATOR_LABELS } from "./DistrictCard";
import DistrictMap from "./DistrictMap";
import RegionPicker from "./RegionPicker";

// Shared district data, fetched once for every tab that uses this component.
let districtsPromise;
const loadDistricts = () => (districtsPromise ??= api("districts/").catch((e) => {
  districtsPromise = undefined;
  throw e;
}));

/** Coloured, selectable districts with animated zoom + the dataset indicators for this tab. */
export default function RegionTab({ indicators, title }) {
  const [data, setData] = useState(null);
  const [error, setError] = useState(null);
  const [selected, setSelected] = useState(null);
  const [showRegions, setShowRegions] = useState(true);

  useEffect(() => {
    loadDistricts().then(setData).catch((e) => setError(e.message));
  }, []);

  if (!data) {
    return (
      <div className="region-tab transport-loading">
        {error ? <div className="banner bad"><i className="fa-solid fa-triangle-exclamation" /> {error}</div>
          : <LoadingOverlay done={false} floor={30} label="Loading districts" />}
      </div>
    );
  }

  return (
    <div className="region-tab">
      <div className="map-toolbar">
        <label className="switch"><input type="checkbox" checked={showRegions} onChange={(e) => setShowRegions(e.target.checked)} /><span /> Districts</label>
        <RegionPicker districts={data.districts} selected={selected} onChange={setSelected} />
      </div>
      <div className="map-wrap">
        <DistrictMap districts={data.districts} selected={selected} showRegions={showRegions} onSelect={setSelected} label={`Loading ${title} map`} />
        {selected != null && <DistrictCard district={data.districts[selected]} indicators={indicators} onClose={() => setSelected(null)} />}
        <div className="map-legend">
          {data.districts.map((d, i) => (
            <button key={d.name} className="legend-btn" onClick={() => setSelected(i)}><i className="swatch" style={{ background: d.color }} /> {d.name}</button>
          ))}
        </div>
      </div>
      <div className="table-scroll t-card flat">
        <table className="district-table">
          <thead>
            <tr><th>District</th><th>Residents</th>{indicators.map((k) => <th key={k}>{INDICATOR_LABELS[k]}<br /><small>0–100 · target 100</small></th>)}</tr>
          </thead>
          <tbody>
            {data.districts.map((d, i) => (
              <tr key={d.name} className={selected === i ? "is-selected" : ""} onClick={() => setSelected(i)}>
                <th><i className="swatch" style={{ background: d.color }} /> {d.name}</th>
                <td>{d.population.toLocaleString("en-US")}</td>
                {indicators.map((k) => {
                  const v = d.indicators[k];
                  return <td key={k} className={v != null && v < 40 ? "crit" : ""}>{v == null ? <span className="muted">no data</span> : v}</td>;
                })}
              </tr>
            ))}
          </tbody>
        </table>
        <small className="muted">Indicators: District_Dataset_EN.docx (below 40 = critical). Population: qazatlas.kz, 1 July 2026.</small>
      </div>
    </div>
  );
}
