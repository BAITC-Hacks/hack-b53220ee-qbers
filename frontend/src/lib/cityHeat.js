// City-services heatmap: ikomekastana.kz only publishes citywide complaint totals, with no
// location or district breakdown. We spread each district's population-weighted share of the
// citywide total across its population grid cells, so the heatmap shows *where people are*
// weighted by *how big that district's utility-complaint problem is* — an estimate, not real
// fault locations. Labelled as such everywhere it's shown.
export function complaintWeightedPoints(cells, districts, districtTotals, cityTotal) {
  if (!cityTotal) return [];
  const points = [];
  for (const [lon, lat, pop, d] of cells) {
    const districtPop = districts[d]?.population || 1;
    const districtShare = districtTotals[d] || 0;
    const weight = (pop / districtPop) * districtShare;
    if (weight > 0) points.push({ lon, lat, weight });
  }
  return points;
}

// Split a citywide count across districts by population (the only split we can justify).
export function splitByPopulation(cityTotal, districts) {
  const totalPop = districts.reduce((a, d) => a + d.population, 0);
  return districts.map((d) => (cityTotal * d.population) / totalPop);
}
