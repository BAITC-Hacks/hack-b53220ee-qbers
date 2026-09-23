import qbersLogo from "./assets/qbers-logo.png";
import { useEffect, useReducer, useRef, useState } from "react";
import AreaTabs from "./components/AreaTabs";
import BudgetControls from "./components/BudgetControls";
import { DndProvider } from "./components/dnd/DndProvider";
import { LoadingOverlay, ProgressBar } from "./components/ProgressBar";
import { useProgress } from "./hooks/useProgress";
import { api } from "./lib/api";
import { AREA_IDS, AREAS } from "./lib/areas";
import { DECIMALS, convert, equalSplit, round, sectionFromApi, sectionToApi, sumOf } from "./lib/money";

// ---------------------------------------------------------------------------
// Budget state
// ---------------------------------------------------------------------------
function withSection(plan, mode, update) {
  return { ...plan, [mode]: { ...plan[mode], ...update }, dirty: true };
}

function budgetReducer(plan, action) {
  if (action.type === "load") return { ...action.plan, dirty: false };
  const mode = plan.mode;
  const d = DECIMALS[mode];
  const section = plan[mode];

  switch (action.type) {
    case "mode":
      return { ...plan, mode: action.mode, dirty: true };

    case "total": {
      const total = Math.max(0, action.total);
      return withSection(plan, mode, {
        total,
        allocations: section.split === "equal" ? equalSplit(total, d) : section.allocations,
      });
    }

    case "split":
      return withSection(plan, mode, {
        split: action.split,
        allocations: action.split === "equal" ? equalSplit(section.total, d) : section.allocations,
      });

    case "allocation":
      return withSection(plan, mode, {
        split: "custom",
        allocations: { ...section.allocations, [action.area]: Math.max(0, action.value) },
      });

    case "distribute": {
      const remaining = round(section.total - sumOf(section.allocations), d);
      if (remaining <= 0) return plan;
      const extra = equalSplit(remaining, d);
      return withSection(plan, mode, {
        allocations: Object.fromEntries(AREA_IDS.map((id) => [id, round(section.allocations[id] + extra[id], d)])),
      });
    }

    case "currency": {
      // Convert the money budget into the new currency so it keeps its real value.
      const { currency: to, rates } = action;
      const money = plan.money;
      const total = round(convert(money.total, plan.currency, to, rates), 2);
      let allocations;
      if (money.split === "equal") {
        allocations = equalSplit(total, 2);
      } else {
        allocations = Object.fromEntries(AREA_IDS.map((id) => [id, round(convert(money.allocations[id], plan.currency, to, rates), 2)]));
        // Rounding can overshoot the total by a cent — take it off the largest area.
        const over = round(sumOf(allocations) - total, 2);
        if (over > 0) {
          const biggest = AREA_IDS.reduce((a, b) => (allocations[a] >= allocations[b] ? a : b));
          allocations[biggest] = round(allocations[biggest] - over, 2);
        }
      }
      return { ...plan, currency: to, money: { ...money, total, allocations }, dirty: true };
    }

    default:
      return plan;
  }
}

const planFromApi = (p) => ({ mode: p.mode, currency: p.currency, money: sectionFromApi(p.money), units: sectionFromApi(p.units) });
const planToApi = (p) => ({
  mode: p.mode,
  currency: p.currency,
  money: sectionToApi(p.money, DECIMALS.money),
  units: sectionToApi(p.units, DECIMALS.units),
});
const overBudget = (p) => ["money", "units"].some((m) => sumOf(p[m].allocations) - p[m].total > 10 ** -DECIMALS[m] / 2);

// ---------------------------------------------------------------------------
// Header pieces
// ---------------------------------------------------------------------------
function DbStatus({ health }) {
  if (!health) return <span className="pill"><i className="fa-solid fa-spinner fa-spin" /> Connecting…</span>;
  const db = health.database;
  return db?.ok ? (
    <span className="pill ok" title={`${db.version} · ${db.host}/${db.name}`}>
      <i className="fa-solid fa-database" /> {db.version.split(" (")[0]} connected
    </span>
  ) : (
    <span className="pill bad" title={db?.version || health.error}>
      <i className="fa-solid fa-database" /> Database offline
    </span>
  );
}

function SaveStatus({ save }) {
  const pct = useProgress(save.state !== "saving");
  if (save.state === "saving") return <div className="save-status"><ProgressBar pct={pct} label="Saving" /></div>;
  if (save.state === "saved") {
    return <span className="save-status ok"><i className="fa-solid fa-cloud-arrow-up" /> Saved {save.at}</span>;
  }
  if (save.state === "blocked") return <span className="save-status warn"><i className="fa-solid fa-pause" /> Not saved — over budget</span>;
  if (save.state === "error") return <span className="save-status bad" title={save.message}><i className="fa-solid fa-triangle-exclamation" /> Save failed</span>;
  return null;
}

// ---------------------------------------------------------------------------
export default function App() {
  const [plan, dispatch] = useReducer(budgetReducer, null);
  const [health, setHealth] = useState(null);
  const [rates, setRates] = useState({ data: null, error: null, done: false, floor: 0 });
  const [loadError, setLoadError] = useState(null);
  const [loaded, setLoaded] = useState({}); // which initial requests have finished
  const [active, setActive] = useState(AREAS[0].id);
  const [save, setSave] = useState({ state: "idle" });
  const saveTimer = useRef(null);

  // Initial page load: health, the saved plan and exchange rates (each fills a third of the bar).
  useEffect(() => {
    // Keyed by name, so React StrictMode running this twice in development is harmless.
    const done = (key) => () => setLoaded((l) => ({ ...l, [key]: true }));
    api("health/")
      .then(setHealth)
      .catch((e) => setHealth({ database: { ok: false, version: e.message }, error: e.message }))
      .finally(done("health"));
    api("plan/")
      .then((p) => dispatch({ type: "load", plan: planFromApi(p) }))
      .catch((e) => setLoadError(e.message))
      .finally(done("plan"));
    api("currency/")
      .then((data) => setRates({ data, error: null, done: true, floor: 100 }))
      .catch((e) => setRates({ data: null, error: e.message, done: true, floor: 100 }))
      .finally(done("currency"));
  }, []);

  // Autosave to Postgres shortly after each change (Django validates it with BudgetPlanForm).
  useEffect(() => {
    if (!plan?.dirty) return undefined;
    clearTimeout(saveTimer.current);
    if (overBudget(plan)) {
      setSave({ state: "blocked" });
      return undefined;
    }
    saveTimer.current = setTimeout(() => {
      setSave({ state: "saving" });
      api("plan/", { method: "PUT", body: planToApi(plan) })
        .then((saved) => setSave({ state: "saved", at: new Date(saved.updated_at).toLocaleTimeString("en-GB", { hour: "2-digit", minute: "2-digit" }) }))
        .catch((e) => setSave({ state: "error", message: e.message }));
    }, 700);
    return () => clearTimeout(saveTimer.current);
  }, [plan]);

  const settled = Object.keys(loaded).length;
  const pageDone = settled === 3;

  return (
    <>
      {/* Page preloader — fills as each of the three initial requests finishes */}
      <LoadingOverlay done={pageDone} floor={(settled / 3) * 90} label="Loading budget planner" className="is-page" />

      <header className="topbar">
        <div className="brand">
          <img className="brand-mark" src={qbersLogo} alt="QBERS" width="56" height="56" />
          <div>
            <strong>Astana Budget Planner</strong>
            <span>Астана қаласының бюджетін жоспарлау</span>
          </div>
        </div>
        <div className="topbar-status">
          {plan && <SaveStatus save={save} />}
          <DbStatus health={health} />
        </div>
      </header>

      <main className="page">
        {loadError && (
          <div className="banner bad">
            <i className="fa-solid fa-triangle-exclamation" /> Couldn't load the budget from the database: {loadError}. Is <code>npm start</code> running?
          </div>
        )}
        {plan && (
          <DndProvider>
            <BudgetControls plan={plan} rates={rates} dispatch={dispatch} />
            <AreaTabs plan={plan} rates={rates} active={active} onSelect={setActive} dispatch={dispatch} />
          </DndProvider>
        )}
      </main>

      <footer className="footer">
        <i className="fa-solid fa-map-location-dot" /> Maps © 2GIS · Exchange rates: currencyapi.com · Team QBERS
      </footer>
    </>
  );
}
