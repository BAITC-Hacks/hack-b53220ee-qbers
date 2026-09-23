// Green-space maths for the greenery tab. Uses the same ≈200 m grid as the backend
// (PopulationCell / GreenCell), so everything lines up cell by cell.
import { KX, KY } from "./geo";

const CELL_LON = 0.0029;
const CELL_LAT = 0.0018;
export const cellKey = (lon, lat) => `${Math.round(lon / CELL_LON)},${Math.round(lat / CELL_LAT)}`;
const keyParts = (key) => key.split(",").map(Number);

// Deterministic random numbers, so a mass planting lands in the same spots after a reload.
function rng(seed) {
  let a = seed >>> 0;
  return () => {
    a = (a + 0x6d2b79f5) >>> 0;
    let t = a;
    t = Math.imul(t ^ (t >>> 15), t | 1);
    t ^= t + Math.imul(t ^ (t >>> 7), t | 61);
    return ((t ^ (t >>> 14)) >>> 0) / 4294967296;
  };
}

function neighbourOffsets(radius) {
  const cw = CELL_LON * KX;
  const ch = CELL_LAT * KY;
  const nx = Math.ceil(radius / cw);
  const ny = Math.ceil(radius / ch);
  const out = [];
  for (let dx = -nx; dx <= nx; dx++) {
    for (let dy = -ny; dy <= ny; dy++) if (Math.hypot(dx * cw, dy * ch) <= radius) out.push([dx, dy]);
  }
  return out;
}

/**
 * Green m² per resident within `radius` of each home cell, before and after new trees.
 * `newTrees` is a Map cellKey → tree count. Returns per-cell ratios and per-district summaries.
 */
export function greenAnalysis({ data, newTrees, radius, goal, includeForest, footprint }) {
  const green = new Map();
  const pop = new Map();
  for (const [lon, lat, park, forest] of data.green_cells) {
    green.set(cellKey(lon, lat), park + (includeForest ? forest : 0));
  }
  for (const [lon, lat, p] of data.cells) pop.set(cellKey(lon, lat), p);
  const offsets = neighbourOffsets(radius);

  const nd = data.districts.length;
  const dist = Array.from({ length: nd }, () => ({ pop: 0, greenBefore: 0, greenAfter: 0, meetsBefore: 0, meetsAfter: 0, trees: 0 }));
  for (const [lon, lat, park, forest, d] of data.green_cells) dist[d].greenBefore += park + (includeForest ? forest : 0);
  for (let d = 0; d < nd; d++) dist[d].greenAfter = dist[d].greenBefore;

  // Where each new tree's cell falls (for the district totals).
  const districtOfKey = new Map(data.cells.map(([lon, lat, , d]) => [cellKey(lon, lat), d]));
  for (const [lon, lat, , , d] of data.green_cells) if (!districtOfKey.has(cellKey(lon, lat))) districtOfKey.set(cellKey(lon, lat), d);

  for (const [key, n] of newTrees) {
    const d = districtOfKey.get(key);
    if (d != null) {
      dist[d].greenAfter += n * footprint;
      dist[d].trees += n;
    }
  }

  const cells = [];
  for (const [lon, lat, p, d] of data.cells) {
    const [cx, cy] = keyParts(cellKey(lon, lat));
    let g = 0;
    let added = 0;
    let people = 0;
    for (const [dx, dy] of offsets) {
      const k = `${cx + dx},${cy + dy}`;
      g += green.get(k) || 0;
      added += (newTrees.get(k) || 0) * footprint;
      people += pop.get(k) || 0;
    }
    const before = people > 0 ? g / people : 0;
    const after = people > 0 ? (g + added) / people : 0;
    cells.push({ lon, lat, pop: p, d, before, after });
    dist[d].pop += p;
    if (before >= goal) dist[d].meetsBefore += p;
    if (after >= goal) dist[d].meetsAfter += p;
  }

  const summary = (x, population) => ({
    population,
    greenBefore: x.greenBefore,
    greenAfter: x.greenAfter,
    perResBefore: population ? x.greenBefore / population : 0,
    perResAfter: population ? x.greenAfter / population : 0,
    shareBefore: x.pop ? (x.meetsBefore / x.pop) * 100 : 0,
    shareAfter: x.pop ? (x.meetsAfter / x.pop) * 100 : 0,
    trees: x.trees,
  });
  const byDistrict = dist.map((x, i) => summary(x, data.districts[i].population));
  const city = dist.reduce(
    (a, x) => ({ pop: a.pop + x.pop, greenBefore: a.greenBefore + x.greenBefore, greenAfter: a.greenAfter + x.greenAfter,
      meetsBefore: a.meetsBefore + x.meetsBefore, meetsAfter: a.meetsAfter + x.meetsAfter, trees: a.trees + x.trees }),
    { pop: 0, greenBefore: 0, greenAfter: 0, meetsBefore: 0, meetsAfter: 0, trees: 0 }
  );
  return { cells, byDistrict, city: summary(city, data.districts.reduce((a, d) => a + d.population, 0)) };
}

/**
 * Turn the saved plantings into tree positions.
 *  - "drop": scattered around the drop point (≈25 m² per tree of planting area)
 *  - "mass": spread over the district's homes, favouring blocks furthest below the goal
 * Returns { perCell: Map cellKey → count, points: [[lon, lat, plantingIndex]] } with at most
 * `maxPoints` points (each point then stands for several trees).
 */
export function expandPlantings({ plantings, data, baseline, goal, maxPoints = 2500 }) {
  const perCell = new Map();
  const total = plantings.reduce((a, p) => a + p.count, 0);
  const perDot = Math.max(1, Math.ceil(total / maxPoints));
  const points = [];
  const add = (key, n) => perCell.set(key, (perCell.get(key) || 0) + n);

  plantings.forEach((p, idx) => {
    const rand = rng(p.seed ?? Math.round(p.lon * 1e6 + p.lat * 1e3));
    if (p.kind === "drop") {
      const r = Math.max(12, Math.sqrt((p.count * 25) / Math.PI)); // metres
      add(cellKey(p.lon, p.lat), p.count);
      const dots = Math.max(1, Math.round(p.count / perDot));
      for (let i = 0; i < dots; i++) {
        const a = rand() * Math.PI * 2;
        const d = Math.sqrt(rand()) * r;
        points.push([p.lon + (Math.cos(a) * d) / KX, p.lat + (Math.sin(a) * d) / KY, idx]);
      }
      return;
    }
    const d = data.districts.findIndex((x) => x.name === p.district);
    const homes = baseline.filter((c) => c.d === d && c.pop > 1);
    if (!homes.length) return;
    // Weight = residents × how far below the goal their neighbourhood is (a little for everyone).
    const weights = homes.map((c) => c.pop * Math.max(0.05, (goal - c.before) / goal));
    const sum = weights.reduce((a, b) => a + b, 0);
    const shares = weights.map((w) => (w / sum) * p.count);
    const counts = shares.map(Math.floor);
    let left = p.count - counts.reduce((a, b) => a + b, 0);
    shares.map((s, i) => [s - counts[i], i]).sort((a, b) => b[0] - a[0]).slice(0, left).forEach(([, i]) => (counts[i] += 1));
    homes.forEach((c, i) => {
      if (!counts[i]) return;
      add(cellKey(c.lon, c.lat), counts[i]);
      const dots = Math.round(counts[i] / perDot) || (rand() < counts[i] / perDot ? 1 : 0);
      for (let k = 0; k < dots; k++) {
        points.push([c.lon + (rand() - 0.5) * CELL_LON, c.lat + (rand() - 0.5) * CELL_LAT, idx]);
      }
    });
  });
  return { perCell, points, perDot, total };
}

// Colour ramp for "green m² per resident near home" (red → amber → green at the goal).
export function needColor(ratio, goal) {
  if (ratio >= goal) return "#43A047";
  if (ratio >= goal * 0.5) return "#C0CA33";
  if (ratio >= goal * 0.25) return "#FFB300";
  return "#E53935";
}

export const cellSquare = (lon, lat) => [[
  [lon - CELL_LON / 2, lat - CELL_LAT / 2], [lon + CELL_LON / 2, lat - CELL_LAT / 2],
  [lon + CELL_LON / 2, lat + CELL_LAT / 2], [lon - CELL_LON / 2, lat + CELL_LAT / 2], [lon - CELL_LON / 2, lat - CELL_LAT / 2],
]];
