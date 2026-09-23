// Children, places and projections for the social-services tab.
//
// Method (cohort model):
//   children aged a in year Y ≈ births(Y − a) × (1 + k·a)
// where k is a migration uplift that grows with age (Astana gains children through
// migration). k is calibrated so the school-age group in the reference year matches the
// actual pupil count. Future births start from the average of the last three years and
// change by `birthsChangePct` a year.

export const SCHOOL_AGES = [6, 16];        // grades 1–11
export const KINDERGARTEN_AGES = [2, 5];   // kindergarten; 6-year-olds start school
export const REF_YEAR = 2025;              // school year 2025/26 ↔ pupil count published June 2026
export const HORIZONS = [0, 5, 10, 15];

const range = ([a, b]) => Array.from({ length: b - a + 1 }, (_, i) => a + i);

export function birthsFn(births, changePct) {
  const years = Object.keys(births).map(Number);
  const last = Math.max(...years);
  const base = [last, last - 1, last - 2].reduce((s, y) => s + (births[y] || 0), 0) / 3;
  return (y) => (births[y] != null ? births[y] : base * (1 + changePct / 100) ** (y - last));
}

/** Solve k so Σ births(ref − a)·(1 + k·a) over school ages = pupils. */
export function calibrateUplift(births, pupils) {
  const ages = range(SCHOOL_AGES);
  const plain = ages.reduce((s, a) => s + (births[REF_YEAR - a] || 0), 0);
  const weighted = ages.reduce((s, a) => s + (births[REF_YEAR - a] || 0) * a, 0);
  return Math.max(0, (pupils - plain) / weighted);
}

export function childrenIn(year, ages, birthsAt, k) {
  return range(ages).reduce((s, a) => s + birthsAt(year - a) * (1 + k * a), 0);
}

/** Readiness: +x% = over-prepared (spare places), −x% = under-prepared. */
export const readiness = (places, children) => (children > 0 ? ((places - children) / children) * 100 : 0);

export function readinessLabel(pct) {
  if (Math.abs(pct) < 0.5) return "just right";
  return pct < 0 ? `under-prepared by ${Math.abs(pct).toFixed(1)}%` : `over-prepared by ${pct.toFixed(1)}%`;
}
