import { SIGNS } from "../../lib/signs";

const GOAL_MIN = 10; // District_Dataset_EN.docx T2: service intervals ≤ 10 min

function Stepper({ value, onChange, label }) {
  return (
    <div className="stepper" role="group" aria-label={label}>
      <button aria-label={`Fewer — ${label}`} onClick={() => onChange(value - 1)} disabled={value <= 0}><i className="fa-solid fa-minus" /></button>
      <input inputMode="numeric" aria-label={label} value={value} onChange={(e) => onChange(Number(e.target.value.replace(/\D/g, "")) || 0)} />
      <button aria-label={`More — ${label}`} onClick={() => onChange(value + 1)}><i className="fa-solid fa-plus" /></button>
    </div>
  );
}

export default function FleetPanel({ routes, newBuses, newTrains, dispatch }) {
  return (
    <section className="t-card">
      <h4><img src={SIGNS.bus} alt="" width="20" height="20" /> Add buses</h4>
      <p className="muted small">
        Real timings from GPS data (Jul–Sep 2024, Zenodo). More buses on a route means shorter waits: interval ≈ now × buses ÷ (buses + added).
      </p>
      <div className="routes">
        {routes.map((r) => {
          const add = newBuses[r.short_name] || 0;
          const after = (r.peak_headway * r.fleet) / (r.fleet + add);
          const meets = after <= GOAL_MIN;
          return (
            <div key={r.short_name} className="route" style={{ "--route": r.color }}>
              <div className="route-head">
                <span className="route-badge">{r.short_name}</span>
                <span className="route-name">{r.long_name}</span>
              </div>
              <dl>
                <div><dt>Buses / day</dt><dd>{r.fleet}</dd></div>
                <div><dt>Peak interval</dt><dd>{r.peak_headway} min</dd></div>
                <div><dt>Trip</dt><dd>{r.trip_minutes} min</dd></div>
                <div><dt>Service</dt><dd>{r.first_departure}–{r.last_departure}</dd></div>
              </dl>
              <div className="route-edit">
                <span>Add buses</span>
                <Stepper value={add} label={`new buses on route ${r.short_name}`}
                  onChange={(v) => dispatch({ type: "newBuses", route: r.short_name, value: v })} />
              </div>
              <div className={`route-after ${meets ? "ok" : "warn"}`}>
                <i className={`fa-solid ${meets ? "fa-circle-check" : "fa-clock"}`} />
                {add > 0 ? <>Every <strong>{after.toFixed(1)} min</strong> (was {r.peak_headway})</> : <>Every {r.peak_headway} min</>}
                <span>{meets ? `meets ≤${GOAL_MIN} min goal` : `goal ≤${GOAL_MIN} min`}</span>
              </div>
            </div>
          );
        })}
      </div>

      <h4><img src={SIGNS.rail} alt="" width="20" height="20" /> Add trains</h4>
      <div className="route-edit">
        <span>New trains</span>
        <Stepper value={newTrains} label="new trains" onChange={(v) => dispatch({ type: "newTrains", value: v })} />
      </div>
      <p className="muted small">No train timetables in the sources yet, so trains count towards cost only.</p>
    </section>
  );
}
