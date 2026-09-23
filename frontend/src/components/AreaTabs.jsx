import { useRef } from "react";
import { AREAS } from "../lib/areas";
import { formatAmount } from "../lib/money";
import CityServicesTab from "./cityservices/CityServicesTab";
import EducationTab from "./education/EducationTab";
import GreeneryTab from "./greenery/GreeneryTab";
import ScoreTab from "./score/ScoreTab";
import SafetyTab from "./safety/SafetyTab";
import TransportTab from "./transport/TransportTab";

// The Indicators tab is a cross-cutting analysis view, not a 6th budget area — it carries no
// allocation of its own, so it's kept out of lib/areas.js (which drives the 5-way budget split).
const INDICATORS_TAB = { id: "indicators", label: "Indicators", icon: "fa-solid fa-chart-line", tint: "#E7E9EF", ink: "#33384A" };
const TABS = [...AREAS, INDICATORS_TAB];

export default function AreaTabs({ plan, rates, active, onSelect, dispatch, onPlanUpdated }) {
  const { mode, currency } = plan;
  const section = plan[mode];
  const tabs = useRef([]);
  const tab = TABS.find((a) => a.id === active) || TABS[0];
  const isIndicators = tab.id === "indicators";

  function onKeyDown(e) {
    const i = TABS.findIndex((a) => a.id === active);
    const next = { ArrowRight: i + 1, ArrowLeft: i - 1, Home: 0, End: TABS.length - 1 }[e.key];
    if (next === undefined) return;
    e.preventDefault();
    const target = TABS[(next + TABS.length) % TABS.length];
    onSelect(target.id);
    tabs.current[TABS.indexOf(target)]?.focus();
  }

  return (
    <section className="areas">
      <div className="tab-list" role="tablist" aria-label="Budget areas and indicators" onKeyDown={onKeyDown}>
        {TABS.map((a, i) => (
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
            {section.allocations[a.id] !== undefined && (
              <span className="tab-amount">{formatAmount(section.allocations[a.id], { mode, currency, compact: true })}</span>
            )}
          </button>
        ))}
      </div>

      <div
        className={`tab-panel ${isIndicators ? "is-indicators" : "is-transport"}`}
        role="tabpanel"
        id={`panel-${tab.id}`}
        aria-labelledby={`tab-${tab.id}`}
        style={{ "--tint": tab.tint, "--ink": tab.ink }}
      >
        {tab.id === "transport" ? (
          <TransportTab plan={plan} rates={rates.data?.rates} />
        ) : tab.id === "greenery" ? (
          <GreeneryTab plan={plan} rates={rates.data?.rates} />
        ) : tab.id === "safety" ? (
          <SafetyTab plan={plan} rates={rates.data?.rates} />
        ) : tab.id === "social" ? (
          <EducationTab plan={plan} rates={rates.data?.rates} />
        ) : tab.id === "city" ? (
          <CityServicesTab plan={plan} rates={rates.data?.rates} />
        ) : (
          <ScoreTab onPlanUpdated={onPlanUpdated} />
        )}
      </div>
    </section>
  );
}
