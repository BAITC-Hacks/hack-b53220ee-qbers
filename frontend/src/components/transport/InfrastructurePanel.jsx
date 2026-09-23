import { districtIndexAt } from "../../lib/geo";
import { SIGNS } from "../../lib/signs";
import { PaletteItem } from "../dnd/DndProvider";
import NumberField from "../NumberField";

function CountBox({ icon, label, value, added, detail }) {
  return (
    <div className="count-box">
      <img src={icon} alt="" width="30" height="30" />
      <div>
        <span className="count-label">{label}</span>
        <strong>{value.toLocaleString("en-US")}</strong>
        {added > 0 && <span className="count-added">+{added} new</span>}
        {detail && <small>{detail}</small>}
      </div>
    </div>
  );
}

export default function InfrastructurePanel({ existing, override, counts, newStops, districts, dispatch, onFocus }) {
  const busStops = override.bus_stops ?? existing.bus_stops;
  const railStations = override.rail_stations ?? existing.rail_stations;

  return (
    <section className="t-card">
      <h4><i className="fa-solid fa-map-pin" /> Current infrastructure</h4>
      <div className="count-grid">
        <CountBox icon={SIGNS.bus} label="Bus stops" value={busStops} added={counts.bus_stop} />
        <CountBox icon={SIGNS.rail} label="Train stations" value={railStations} added={counts.rail_station}
          detail={`${existing.rail_only} railway · ${existing.lrt} LRT`} />
      </div>

      <div className="autofill">
        <div className="field">
          <span>Existing bus stops <small>auto-filled from the map data</small></span>
          <NumberField value={busStops} decimals={0} ariaLabel="Existing bus stops"
            onChange={(v) => dispatch({ type: "existing", key: "bus_stops", value: v })} />
        </div>
        {override.bus_stops != null && override.bus_stops !== existing.bus_stops && (
          <button className="link-btn" onClick={() => dispatch({ type: "existing", key: "bus_stops", value: null })}>
            Reset to {existing.bus_stops.toLocaleString("en-US")} from the data
          </button>
        )}
        <div className="field">
          <span>Existing train stations <small>auto-filled from the map data</small></span>
          <NumberField value={railStations} decimals={0} ariaLabel="Existing train stations"
            onChange={(v) => dispatch({ type: "existing", key: "rail_stations", value: v })} />
        </div>
        {override.rail_stations != null && override.rail_stations !== existing.rail_stations && (
          <button className="link-btn" onClick={() => dispatch({ type: "existing", key: "rail_stations", value: null })}>
            Reset to {existing.rail_stations} from the data
          </button>
        )}
        <small className="muted">Edited counts feed the density figures; coverage always uses the stops on the map.</small>
      </div>

      <h4><i className="fa-solid fa-hand-pointer" /> Add stops — drag onto the map</h4>
      <small className="muted">Drag a sign onto the map. Placed signs can be dragged again to move them.</small>
      <div className="palette">
        <PaletteItem id="palette-bus" kind="bus" label="Bus stop" icon={SIGNS.newBus} />
        <PaletteItem id="palette-rail" kind="rail" label="Train station" icon={SIGNS.newRail} />
      </div>

      {newStops.length > 0 && (
        <>
          <ul className="new-stops">
            {newStops.map((s, i) => {
              const d = districtIndexAt(s.lon, s.lat, districts);
              return (
                <li key={`${s.lon},${s.lat},${i}`}>
                  <img src={s.kind === "rail" ? SIGNS.newRail : SIGNS.newBus} alt="" width="24" height="24" />
                  <button className="link-btn plain" onClick={() => onFocus(s)} title="Show on map">
                    {s.kind === "rail" ? "Train station" : "Bus stop"} #{i + 1}
                    <small>{d >= 0 ? districts[d].name : "outside districts"}</small>
                  </button>
                  <button className="icon-btn" aria-label={`Remove new stop ${i + 1}`} onClick={() => dispatch({ type: "removeStop", index: i })}>
                    <i className="fa-solid fa-xmark" />
                  </button>
                </li>
              );
            })}
          </ul>
          <button className="link-btn" onClick={() => dispatch({ type: "clearStops" })}>Remove all new stops</button>
        </>
      )}
    </section>
  );
}
