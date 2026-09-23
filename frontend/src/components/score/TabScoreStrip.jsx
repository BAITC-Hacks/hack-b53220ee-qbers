import { useEffect, useState } from "react";
import { api } from "../../lib/api";

/** Population-weighted average of one indicator across the 5 docx districts. */
function weightedAvg(rows, districts, key) {
  let sum = 0;
  let weight = 0;
  for (const d of districts) {
    const r = rows[d.name];
    if (!r || !d.in_dataset) continue;
    sum += r.values[key] * r.share;
    weight += r.share;
  }
  return weight > 0 ? sum / weight : null;
}

/**
 * A compact "/100" strip for the bottom of one budget-area tab, showing the district-dataset
 * indicator(s) that area's tools actually move — before your changes and after, city-wide.
 * See the Indicators tab for the full per-district breakdown and how this is calculated.
 */
export default function TabScoreStrip({ indicators }) {
  const [score, setScore] = useState(null);
  const [error, setError] = useState(null);

  useEffect(() => {
    api("score/").then(setScore).catch((e) => setError(e.message));
  }, []);

  if (error || !score) return null; // non-critical — fail quietly rather than block the tab

  return (
    <div className="tab-score-strip">
      <span className="strip-title"><i className="fa-solid fa-bullseye" /> District dataset — this tab's score</span>
      {indicators.map((key) => {
        const before = weightedAvg(score.before.rows, score.districts, key);
        const after = weightedAvg(score.after.rows, score.districts, key);
        if (before == null) return null;
        const changed = after > before + 0.05;
        return (
          <span key={key} className="tab-score-item">
            <span>{score.labels[key]}</span>
            <strong>
              {before.toFixed(0)}/100{changed && <> <i className="fa-solid fa-arrow-right" /> <strong className="up">{after.toFixed(0)}/100</strong></>}
            </strong>
          </span>
        );
      })}
      <a href="#indicators-tab-hint" className="link-btn tab-score-link" onClick={(e) => { e.preventDefault(); document.querySelector('[id="tab-indicators"]')?.click(); }}>
        Full breakdown in Indicators →
      </a>
    </div>
  );
}
