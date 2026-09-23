import { formatAmount, fromKzt, kztPerUnit, rateOf, toKzt } from "../../lib/money";
import { SIGNS } from "../../lib/signs";
import NumberField from "../NumberField";

const ROWS = [
  { asset: "bus_stop", label: "Bus stop", icon: SIGNS.bus },
  { asset: "rail_station", label: "Train station", icon: SIGNS.rail },
  { asset: "bus", label: "Bus", icon: SIGNS.bus },
  { asset: "train", label: "Train", icon: SIGNS.rail },
];

// Totals in tenge: setup (one-off) and maintenance per year for the new assets.
export function costSummary(costs, counts) {
  let setup = 0;
  let maintenanceYear = 0;
  for (const { asset } of ROWS) {
    setup += counts[asset] * costs[asset].setup_kzt;
    maintenanceYear += counts[asset] * costs[asset].maintenance_kzt_month * 12;
  }
  return { setup, maintenanceYear };
}

function MeasureSelect({ value, onChange, currency, label }) {
  return (
    <select className="mini-select" aria-label={label} value={value} onChange={(e) => onChange(e.target.value)}>
      <option value="money">{currency}</option>
      <option value="units">units</option>
    </select>
  );
}

export default function CostTable({ costs, counts, plan, rates, dispatch, summary }) {
  const cur = plan.currency;
  const decimalsFor = (measure) => (measure === "units" ? 2 : 0);
  const show = (kzt, measure) => fromKzt(kzt, measure, plan, rates);
  const fmtPlan = (kzt) => formatAmount(fromKzt(kzt, plan.mode, plan, rates), { mode: plan.mode, currency: cur });
  const unitValue = kztPerUnit(plan, rates) * rateOf(cur, rates);

  return (
    <section className="t-card">
      <h4><i className="fa-solid fa-coins" /> Costs</h4>
      <p className="muted small">
        Pre-filled planning estimates — edit them to match real quotes. Maintenance can be entered in {cur} or units, per month or per year.
        1 unit = {formatAmount(unitValue, { mode: "money", currency: cur })} (money budget ÷ units budget).
      </p>
      <div className="table-scroll">
        <table className="cost-table">
          <thead>
            <tr>
              <th>Item</th>
              <th>New</th>
              <th>Purchase / setup cost <small>each</small></th>
              <th>Maintenance <small>each</small></th>
              <th>Setup total</th>
              <th>Maintenance / year</th>
            </tr>
          </thead>
          <tbody>
            {ROWS.map(({ asset, label, icon }) => {
              const c = costs[asset];
              const perMonth = c.maintenance_kzt_month;
              const maintShown = show(c.maintenance_period === "year" ? perMonth * 12 : perMonth, c.maintenance_measure);
              return (
                <tr key={asset}>
                  <th><img src={icon} alt="" width="20" height="20" /> {label}</th>
                  <td className="num">{counts[asset]}</td>
                  <td>
                    <div className="cost-input">
                      <NumberField value={show(c.setup_kzt, c.setup_measure)} decimals={decimalsFor(c.setup_measure)} ariaLabel={`${label} setup cost`}
                        onChange={(v) => dispatch({ type: "cost", asset, patch: { setup_kzt: toKzt(v, c.setup_measure, plan, rates) } })} />
                      <MeasureSelect value={c.setup_measure} currency={cur} label={`${label} setup cost measure`}
                        onChange={(m) => dispatch({ type: "cost", asset, patch: { setup_measure: m } })} />
                    </div>
                  </td>
                  <td>
                    <div className="cost-input">
                      <NumberField value={maintShown} decimals={decimalsFor(c.maintenance_measure)} ariaLabel={`${label} maintenance cost`}
                        onChange={(v) => {
                          const kzt = toKzt(v, c.maintenance_measure, plan, rates);
                          dispatch({ type: "cost", asset, patch: { maintenance_kzt_month: c.maintenance_period === "year" ? kzt / 12 : kzt } });
                        }} />
                      <MeasureSelect value={c.maintenance_measure} currency={cur} label={`${label} maintenance measure`}
                        onChange={(m) => dispatch({ type: "cost", asset, patch: { maintenance_measure: m } })} />
                      <select className="mini-select" aria-label={`${label} maintenance period`} value={c.maintenance_period}
                        onChange={(e) => dispatch({ type: "cost", asset, patch: { maintenance_period: e.target.value } })}>
                        <option value="month">/ month</option>
                        <option value="year">/ year</option>
                      </select>
                    </div>
                  </td>
                  <td className="num">{fmtPlan(counts[asset] * c.setup_kzt)}</td>
                  <td className="num">{fmtPlan(counts[asset] * perMonth * 12)}</td>
                </tr>
              );
            })}
          </tbody>
          <tfoot>
            <tr>
              <th colSpan={4}>Initial purchase / setup</th>
              <td className="num" colSpan={2}>{fmtPlan(summary.setup)}</td>
            </tr>
            <tr>
              <th colSpan={4}>Maintenance per year</th>
              <td className="num" colSpan={2}>{fmtPlan(summary.maintenanceYear)}</td>
            </tr>
            <tr className="grand">
              <th colSpan={4}>First-year total</th>
              <td className="num" colSpan={2}>{fmtPlan(summary.setup + summary.maintenanceYear)}</td>
            </tr>
          </tfoot>
        </table>
      </div>
    </section>
  );
}
