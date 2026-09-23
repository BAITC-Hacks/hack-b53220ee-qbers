import { useState } from "react";
import CurrencyPicker from "./CurrencyPicker";
import { AREAS } from "../lib/areas";
import { api } from "../lib/api";
import { DECIMALS, PINNED_CURRENCIES, formatAmount, isCurrencyCode, sectionFromApi, sumOf } from "../lib/money";
import NumberField from "./NumberField";
import { LoadingOverlay } from "./ProgressBar";

function AiAllocateButton({ dispatch }) {
  const [state, setState] = useState({ status: "idle" });

  async function run() {
    setState({ status: "running" });
    try {
      const res = await api("ai/allocate/", { method: "POST", body: {} });
      dispatch({ type: "load", plan: { mode: res.plan.mode, currency: res.plan.currency, money: sectionFromApi(res.plan.money), units: sectionFromApi(res.plan.units) } });
      setState({ status: "done", rationale: res.rationale, split: res.split });
    } catch (e) {
      setState({ status: "error", message: e.data?.error || e.message });
    }
  }

  return (
    <div className="ai-allocate-wrap">
      <button
        type="button"
        className="ai-allocate-btn"
        onClick={run}
        disabled={state.status === "running"}
        title="OpenAI will read each district's weakest indicators and split your budget across the five areas to maximise the Final Score."
      >
        <i className={state.status === "running" ? "fa-solid fa-spinner fa-spin" : "fa-brands fa-openai"} />
        AI allocate budget
      </button>
      {state.status === "done" && (
        <div className="ai-allocate-result">
          <strong>{Object.entries(state.split).map(([k, v]) => `${k} ${v.toFixed(0)}%`).join(" · ")}</strong>
          <p>{state.rationale}</p>
        </div>
      )}
      {state.status === "error" && (
        <div className="ai-allocate-result"><i className="fa-solid fa-triangle-exclamation" /> {state.message}</div>
      )}
    </div>
  );
}

export default function BudgetControls({ plan, rates, dispatch }) {
  const { mode, currency } = plan;
  const section = plan[mode];
  const decimals = DECIMALS[mode];
  const allocated = sumOf(section.allocations);
  const remaining = Math.round((section.total - allocated) * 10 ** decimals) / 10 ** decimals;
  const fmt = (v, compact) => formatAmount(v, { mode, currency, compact });

  const codes = rates.data ? Object.keys(rates.data.rates).filter(isCurrencyCode) : ["KZT"];
  const pinned = PINNED_CURRENCIES.filter((c) => codes.includes(c));
  const others = codes.filter((c) => !pinned.includes(c)).sort();
  const kztEquivalent = mode === "money" && currency !== "KZT" && rates.data
    ? formatAmount(section.total / rates.data.rates[currency], { mode, currency: "KZT" })
    : null;

  return (
    <section className="budget-controls" aria-labelledby="budget-heading">
      <div className="budget-row">
        <div className="budget-title">
          <h2 id="budget-heading">
            <i className="fa-solid fa-landmark" /> Overall budget
          </h2>
          <p>Set the city budget, then split it across the five areas.</p>
        </div>

        <div className="segmented" role="radiogroup" aria-label="Budget type">
          {[
            { id: "money", icon: "fa-solid fa-money-bill-wave", label: "Money" },
            { id: "units", icon: "fa-solid fa-cubes", label: "Units" },
          ].map((opt) => (
            <button
              key={opt.id}
              role="radio"
              aria-checked={mode === opt.id}
              className={mode === opt.id ? "is-active" : ""}
              onClick={() => dispatch({ type: "mode", mode: opt.id })}
            >
              <i className={opt.icon} /> {opt.label}
            </button>
          ))}
        </div>

        <div className="total-input">
          <NumberField
            ariaLabel={mode === "money" ? `Total budget in ${currency}` : "Total budget in units"}
            value={section.total}
            decimals={decimals}
            suffix={mode === "units" ? "units" : null}
            onChange={(total) => dispatch({ type: "total", total })}
          />
          {mode === "money" && (
            <div className="currency-select">
              <CurrencyPicker
                value={currency}
                pinned={pinned}
                others={others}
                disabled={!rates.data}
                onChange={(code) => dispatch({ type: "currency", currency: code, rates: rates.data.rates })}
              />
              {!rates.done && <LoadingOverlay done={rates.done} floor={rates.floor} label="Exchange rates" className="is-compact" />}
            </div>
          )}
        </div>
      </div>

      <div className="budget-meta">
        {mode === "money" && rates.data && (
          <span>
            <i className="fa-solid fa-arrow-right-arrow-left" /> Rates from currencyapi.com
            {rates.data.source_updated_at && ` · ${new Date(rates.data.source_updated_at).toLocaleDateString("en-GB")}`}
            {kztEquivalent && <> · Total ≈ <strong>{kztEquivalent}</strong></>}
          </span>
        )}
        {mode === "money" && rates.error && (
          <span className="warn"><i className="fa-solid fa-triangle-exclamation" /> {rates.error} — using tenge only.</span>
        )}
        {rates.data?.warning && <span className="warn"><i className="fa-solid fa-circle-info" /> {rates.data.warning}</span>}
      </div>

      <div className="split-row">
        <div className="segmented small" role="radiogroup" aria-label="How to split">
          <button role="radio" aria-checked={section.split === "equal"} className={section.split === "equal" ? "is-active" : ""}
            onClick={() => dispatch({ type: "split", split: "equal" })}>
            <i className="fa-solid fa-equals" /> Split equally
          </button>
          <button role="radio" aria-checked={section.split === "custom"} className={section.split === "custom" ? "is-active" : ""}
            onClick={() => dispatch({ type: "split", split: "custom" })}>
            <i className="fa-solid fa-sliders" /> Custom
          </button>
        </div>

        <AiAllocateButton dispatch={dispatch} />

        {section.split === "custom" && (
          <div className={`remaining ${remaining < 0 ? "over" : remaining > 0 ? "left" : "exact"}`}>
            {remaining < 0 ? (
              <><i className="fa-solid fa-circle-exclamation" /> Over budget by <strong>{fmt(-remaining)}</strong> — not saved until fixed</>
            ) : remaining > 0 ? (
              <>
                <i className="fa-solid fa-piggy-bank" /> Unallocated: <strong>{fmt(remaining)}</strong>
                <button className="link-btn" onClick={() => dispatch({ type: "distribute" })}>Split remaining equally</button>
              </>
            ) : (
              <><i className="fa-solid fa-circle-check" /> Fully allocated</>
            )}
            <button className="link-btn" onClick={() => dispatch({ type: "split", split: "equal" })}>Reset to equal</button>
          </div>
        )}
      </div>

      <div className="allocation-grid">
        {AREAS.map((area) => (
          <div key={area.id} className="allocation" style={{ "--tint": area.tint, "--ink": area.ink }}>
            <span className="allocation-label"><i className={area.icon} /> {area.label}</span>
            {section.split === "custom" ? (
              <NumberField
                ariaLabel={`${area.label} budget`}
                value={section.allocations[area.id]}
                decimals={decimals}
                invalid={remaining < 0}
                onChange={(value) => dispatch({ type: "allocation", area: area.id, value })}
              />
            ) : (
              <strong className="allocation-value">{fmt(section.allocations[area.id])}</strong>
            )}
            <span className="allocation-share">
              {section.total > 0 ? ((section.allocations[area.id] / section.total) * 100).toFixed(1) : "0.0"}% of total
            </span>
          </div>
        ))}
      </div>
    </section>
  );
}
