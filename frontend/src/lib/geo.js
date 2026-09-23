// Distance + coverage maths for the transport tab (flat-earth approximation — fine at city scale).
const LAT0 = 51.15; // Astana
export const KX = 111320 * Math.cos((LAT0 * Math.PI) / 180); // metres per degree of longitude
export const KY = 110540; // metres per degree of latitude

export const metres = (lon1, lat1, lon2, lat2) => Math.hypot((lon2 - lon1) * KX, (lat2 - lat1) * KY);

// Grid index of points (projected to metres) so "any point within r?" checks are fast.
export function buildIndex(points, radius) {
  const size = Math.max(250, radius / 2);
  const buckets = new Map();
  for (const [lon, lat] of points) {
    const x = lon * KX;
    const y = lat * KY;
    const key = `${Math.floor(x / size)},${Math.floor(y / size)}`;
    if (!buckets.has(key)) buckets.set(key, []);
    buckets.get(key).push(x, y);
  }
  return { size, buckets, radius };
}

export function anyWithin(index, lon, lat) {
  const { size, buckets, radius } = index;
  const x = lon * KX;
  const y = lat * KY;
  const r2 = radius * radius;
  const cx = Math.floor(x / size);
  const cy = Math.floor(y / size);
  const n = Math.ceil(radius / size);
  for (let dx = -n; dx <= n; dx++) {
    for (let dy = -n; dy <= n; dy++) {
      const b = buckets.get(`${cx + dx},${cy + dy}`);
      if (!b) continue;
      for (let i = 0; i < b.length; i += 2) {
        const ddx = b[i] - x;
        const ddy = b[i + 1] - y;
        if (ddx * ddx + ddy * ddy <= r2) return true;
      }
    }
  }
  return false;
}

// Point-in-polygon (ray casting) on [[lon, lat], …] rings.
function inRing(lon, lat, ring) {
  let inside = false;
  for (let i = 0, j = ring.length - 1; i < ring.length; j = i++) {
    const [xi, yi] = ring[i];
    const [xj, yj] = ring[j];
    if (yi > lat !== yj > lat && lon < ((xj - xi) * (lat - yi)) / (yj - yi) + xi) inside = !inside;
  }
  return inside;
}

export function inDistrict(lon, lat, d) {
  const [minX, minY, maxX, maxY] = d.bbox;
  if (lon < minX || lon > maxX || lat < minY || lat > maxY) return false;
  return d.outline.some((r) => inRing(lon, lat, r)) && !d.holes.some((r) => inRing(lon, lat, r));
}

export const districtIndexAt = (lon, lat, districts) => districts.findIndex((d) => inDistrict(lon, lat, d));

// Pair each outer ring with the holes that sit inside it (for drawing polygons).
export function polygonsOf(d) {
  return d.outline.map((outer) => [outer, ...d.holes.filter((h) => inRing(h[0][0], h[0][1], outer))]);
}

export function boundsOf(bboxes) {
  return {
    southWest: [Math.min(...bboxes.map((b) => b[0])), Math.min(...bboxes.map((b) => b[1]))],
    northEast: [Math.max(...bboxes.map((b) => b[2])), Math.max(...bboxes.map((b) => b[3]))],
  };
}

/**
 * Share of residents within walking distance of transport, before and after new stops.
 * One pass over the population cells, district by district (yielding in between so the
 * pastel progress bar can animate). Each cell carries [lon, lat, population, districtIndex].
 *
 * Returns { city, byDistrict[] } where each entry is
 *   { busOld, busNew, railOld, railNew, anyOld, anyNew }  as percentages of residents.
 */
export async function proximity({ cells, districts, busOld, busNew, railOld, railNew, busRadius, railRadius, onProgress }) {
  const idx = {
    busOld: buildIndex(busOld, busRadius),
    busNew: buildIndex(busNew, busRadius),
    railOld: buildIndex(railOld, railRadius),
    railNew: buildIndex(railNew, railRadius),
  };
  const keys = ["busOld", "busNew", "railOld", "railNew", "anyOld", "anyNew"];
  const blank = () => Object.fromEntries(keys.map((k) => [k, 0]));
  const covered = districts.map(blank);
  const totals = districts.map(() => 0);
  const byDistrict = districts.map(() => []);
  for (const c of cells) byDistrict[c[3]].push(c);

  for (let d = 0; d < districts.length; d++) {
    const acc = covered[d];
    for (const [lon, lat, pop] of byDistrict[d]) {
      totals[d] += pop;
      const bo = anyWithin(idx.busOld, lon, lat);
      const ro = anyWithin(idx.railOld, lon, lat);
      // New stops only add coverage, so skip the "new" checks when "old" already covers the cell.
      const bn = bo || (busNew.length > busOld.length && anyWithin(idx.busNew, lon, lat));
      const rn = ro || (railNew.length > railOld.length && anyWithin(idx.railNew, lon, lat));
      if (bo) acc.busOld += pop;
      if (bn) acc.busNew += pop;
      if (ro) acc.railOld += pop;
      if (rn) acc.railNew += pop;
      if (bo || ro) acc.anyOld += pop;
      if (bn || rn) acc.anyNew += pop;
    }
    onProgress?.((d + 1) / districts.length);
    await new Promise((r) => setTimeout(r, 0));
  }

  const asPct = (acc, total) => Object.fromEntries(keys.map((k) => [k, total > 0 ? (acc[k] / total) * 100 : 0]));
  const cityAcc = blank();
  covered.forEach((acc) => keys.forEach((k) => (cityAcc[k] += acc[k])));
  return {
    city: asPct(cityAcc, totals.reduce((a, b) => a + b, 0)),
    byDistrict: covered.map((acc, i) => asPct(acc, totals[i])),
  };
}
