import { useRef } from "react";
import { AREAS } from "../lib/areas";
import { DECIMALS, formatAmount } from "../lib/money";
import DgisMap from "./DgisMap";
import NumberField from "./NumberField";
import GreeneryTab from "./greenery/GreeneryTab";
import TransportTab from "./transport/TransportTab";

export default function AreaTabs({ plan, rates, active, onSelect, dispatch }) {
  const { mode, currency } = plan;
  const section = plan[mode];
  const tabs = useRef([]);
  const area = AREAS.find((a) => a.id === active);
  const value = section.allocations[area.id];
  const share = section.total > 0 ? (value / section.total) * 100 : 0;
  const kzt = mode === "money" && currency !== "KZT" && rates.data?.rates[currency]
    ? formatAmount(value / rates.data.rates[currency], { mode, currency: "KZT" })
    : null;

  // Arrow keys move between tabs (WAI-ARIA tabs pattern).
  function onKeyDown(e) {
    const i = AREAS.findIndex((a) => a.id === active);
    const next = { ArrowRight: i + 1, ArrowLeft: i - 1, Home: 0, End: AREAS.length - 1 }[e.key];
    if (next === undefined) return;
    e.preventDefault();
    const target = AREAS[(next + AREAS.length) % AREAS.length];
    onSelect(target.id);
    tabs.current[AREAS.indexOf(target)]?.focus();
  }

  return (
    <section className="areas">
      <div className="tab-list" role="tablist" aria-label="Budget areas" onKeyDown={onKeyDown}>
        {AREAS.map((a, i) => (
          <button
            key={a.id}
            ref={(el) => (tabs.current[i] = el)}
            role="tab"
            id={`tab-${a.id}`}
            aria-selected={a.id === active}
            aria-controls={`panel-${a.id}`}
            tabIndex={a.id === active ? 0 : -1}
            className={`tab ${a.id === active ? "is-active" : ""}`}
            style={{ "--tint": a.tint, "--ink": a.ink }}
            onClick={() => onSelect(a.id)}
          >
            <i className={a.icon} />
            <span className="tab-label">{a.label}</span>
            <span className="tab-amount">{formatAmount(section.allocations[a.id], { mode, currency, compact: true })}</span>
          </button>
        ))}
      </div>

      <div
        className={`tab-panel ${area.id === "transport" || area.id === "greenery" ? "is-transport" : ""}`}
        role="tabpanel"
        id={`panel-${area.id}`}
        aria-labelledby={`tab-${area.id}`}
        style={{ "--tint": area.tint, "--ink": area.ink }}
      >
        {area.id === "transport" ? (
          <TransportTab plan={plan} rates={rates.data?.rates} />
        ) : area.id === "greenery" ? (
          <GreeneryTab plan={plan} rates={rates.data?.rates} />
        ) : (
        <>
        <aside className="area-budget">
          <div className="area-icon"><i className={area.icon} /></div>
          <h3>{area.label}</h3>
          <p className="area-blurb">{area.blurb}</p>

          <span className="area-caption">Budget for this area</span>
          <strong className="area-amount">{formatAmount(value, { mode, currency })}</strong>
          {kzt && <span className="area-kzt">≈ {kzt}</span>}

          <div className="share">
            <div className="share-bar"><div style={{ width: `${Math.min(100, share)}%` }} /></div>
            <span>{share.toFixed(1)}% of {formatAmount(section.total, { mode, currency, compact: true })}</span>
          </div>

          <div className="area-edit">
            <span className="area-caption">Set a custom amount</span>
            <NumberField
              ariaLabel={`Custom ${area.label} budget`}
              value={value}
              decimals={DECIMALS[mode]}
              suffix={mode === "units" ? "units" : currency}
              onChange={(v) => dispatch({ type: "allocation", area: area.id, value: v })}
            />
            <small>{section.split === "equal" ? "Editing switches the split to Custom." : "Custom split is on."}</small>
          </div>
        </aside>

        {/* key: a new map (and preloader) every time this tab is opened */}
        <DgisMap key={area.id} label={area.label} />
        </>
        )}
      </div>
    </section>
  );
}
