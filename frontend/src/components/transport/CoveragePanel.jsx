import NumberField from "../NumberField";
import { LoadingOverlay } from "../ProgressBar";

const pct = (v) => (v == null ? "—" : `${v.toFixed(1)}%`);

export function Meter({ label, icon, old, now, goal, format = pct, max = 100 }) {
  const gain = now - old;
  return (
    <div className="meter">
      <span className="meter-label"><i className={icon} /> {label}</span>
      <div className="meter-values">
        <span className="old" title="Before">{format(old)}</span>
        <i className="fa-solid fa-arrow-right" />
        <strong title="After your changes">{format(now)}</strong>
        {gain > 0.05 && <span className="gain">+{max === 100 ? `${gain.toFixed(1)} pts` : format(gain)}</span>}
      </div>
      <div className="meter-bar" aria-hidden>
        <div className="meter-old" style={{ width: `${Math.min(100, (old / max) * 100)}%` }} />
        <div className="meter-new" style={{ left: `${Math.min(100, (old / max) * 100)}%`, width: `${Math.max(0, Math.min(100 - (old / max) * 100, (gain / max) * 100))}%` }} />
        {goal != null && <div className="meter-goal" style={{ left: `${Math.min(100, (goal / max) * 100)}%` }} title={`Goal ${format(goal)}`} />}
      </div>
      {goal != null && (
        <small className={now >= goal ? "ok" : "warn"}>
          {now >= goal ? <><i className="fa-solid fa-circle-check" /> Meets the {format(goal)} goal</> : <>{max === 100 ? `${(goal - now).toFixed(1)} pts` : format(goal - now)} short of the {format(goal)} goal</>}
        </small>
      )}
    </div>
  );
}

export default function CoveragePanel({ data, scenario, result, calc, existing, newByDistrict, dispatch, onRecalculate }) {
  const { distances, goals, existing_override: override } = scenario;
  const totalPop = data.districts.reduce((a, d) => a + d.population, 0);
  const busStops = override.bus_stops ?? existing.bus_stops;
  const addedBus = newByDistrict.reduce((a, d) => a + d.bus, 0);
  const densityOld = (busStops / totalPop) * 10_000;
  const densityNew = ((busStops + addedBus) / totalPop) * 10_000;
  const city = result?.city;

  return (
    <section className="t-card coverage">
      <header className="coverage-head">
        <h4><i className="fa-solid fa-person-walking" /> Walking distance to transport</h4>
        <button className="btn-small" onClick={onRecalculate} disabled={calc.running}>
          <i className={`fa-solid ${calc.running ? "fa-spinner fa-spin" : "fa-calculator"}`} /> Calculate
        </button>
      </header>

      <div className="coverage-inputs">
        <div className="field"><span>Max distance to a bus stop</span>
          <NumberField value={distances.bus} decimals={0} suffix="m" ariaLabel="Maximum distance to a bus stop in metres"
            onChange={(v) => v >= 50 && v <= 5000 && dispatch({ type: "distance", kind: "bus", value: v })} /></div>
        <div className="field"><span>Max distance to a train station</span>
          <NumberField value={distances.rail} decimals={0} suffix="m" ariaLabel="Maximum distance to a train station in metres"
            onChange={(v) => v >= 50 && v <= 5000 && dispatch({ type: "distance", kind: "rail", value: v })} /></div>
        <div className="field"><span>Goal: residents near a bus stop</span>
          <NumberField value={goals.bus_coverage} decimals={1} suffix="%" ariaLabel="Bus coverage goal"
            onChange={(v) => v <= 100 && dispatch({ type: "goal", key: "bus_coverage", value: v })} /></div>
        <div className="field"><span>Goal: residents near a station</span>
          <NumberField value={goals.rail_coverage} decimals={1} suffix="%" ariaLabel="Train coverage goal"
            onChange={(v) => v <= 100 && dispatch({ type: "goal", key: "rail_coverage", value: v })} /></div>
        <div className="field"><span>Goal: bus stops per 10,000 residents</span>
          <NumberField value={goals.stops_per_10k} decimals={1} ariaLabel="Stop density goal"
            onChange={(v) => dispatch({ type: "goal", key: "stops_per_10k", value: v })} /></div>
      </div>
      <small className="muted">
        The district dataset's T2 indicator scores 100 when every resident is within 500 m of a stop with buses at least every 10 min.
      </small>

      <div className="coverage-body">
        {calc.running && <LoadingOverlay done={false} floor={calc.floor} label="Calculating coverage" />}
        <div className="meters">
          <Meter label={`Within ${distances.bus} m of a bus stop`} icon="fa-solid fa-bus" old={city?.busOld ?? 0} now={city?.busNew ?? 0} goal={goals.bus_coverage} />
          <Meter label={`Within ${distances.rail} m of a station`} icon="fa-solid fa-train" old={city?.railOld ?? 0} now={city?.railNew ?? 0} goal={goals.rail_coverage} />
          <Meter label="Near either" icon="fa-solid fa-route" old={city?.anyOld ?? 0} now={city?.anyNew ?? 0} />
          <div className="meter">
            <span className="meter-label"><i className="fa-solid fa-chart-simple" /> Transport density</span>
            <div className="meter-values">
              <span className="old">{densityOld.toFixed(2)}</span>
              <i className="fa-solid fa-arrow-right" />
              <strong>{densityNew.toFixed(2)}</strong>
              <span className="unit">stops / 10k residents</span>
            </div>
            <small className={densityNew >= goals.stops_per_10k ? "ok" : "warn"}>
              {densityNew >= goals.stops_per_10k
                ? <><i className="fa-solid fa-circle-check" /> Meets the {goals.stops_per_10k} goal</>
                : <>{Math.ceil(((goals.stops_per_10k * totalPop) / 10_000) - busStops - addedBus).toLocaleString("en-US")} more stops to reach {goals.stops_per_10k}</>}
            </small>
          </div>
        </div>

        <div className="table-scroll">
          <table className="district-table">
            <thead>
              <tr>
                <th>District</th>
                <th>Residents</th>
                <th>Bus ≤{distances.bus} m<br /><small>before → after</small></th>
                <th>Station ≤{distances.rail} m<br /><small>before → after</small></th>
                <th>Stops / 10k<br /><small>before → after</small></th>
              </tr>
            </thead>
            <tbody>
              {data.districts.map((d, i) => {
                const r = result?.byDistrict[i];
                const stopsHere = data.bus_stops.filter((s) => s[2] === i).length;
                const dOld = (stopsHere / d.population) * 10_000;
                const dNew = ((stopsHere + newByDistrict[i].bus) / d.population) * 10_000;
                return (
                  <tr key={d.name}>
                    <th><i className="swatch" style={{ background: d.color }} /> {d.name}</th>
                    <td>{d.population.toLocaleString("en-US")}</td>
                    <td>{pct(r?.busOld)} → <strong className={r && r.busNew > r.busOld + 0.05 ? "up" : ""}>{pct(r?.busNew)}</strong></td>
                    <td>{pct(r?.railOld)} → <strong className={r && r.railNew > r.railOld + 0.05 ? "up" : ""}>{pct(r?.railNew)}</strong></td>
                    <td>{dOld.toFixed(2)} → <strong className={dNew > dOld ? "up" : ""}>{dNew.toFixed(2)}</strong></td>
                  </tr>
                );
              })}
            </tbody>
          </table>
        </div>
      </div>
    </section>
  );
}
