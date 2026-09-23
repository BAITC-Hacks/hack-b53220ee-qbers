"""District_Dataset_EN.docx scoring: the 10 indicators, weights and the Score formula.

    D_d      = Σ w_k · I'_dk                              (one district's score)
    D_avg    = Σ pop_share_d · D_d                         (population-weighted city score)
    Score    = 0.7·D_avg + 0.3·min(D_d) − 1.0·N_crit       (N_crit = pairs below 40)

This module also projects how *our* budget tools move each indicator. There is no
official model connecting "buy 3 bus stops" to "T2 +x", so we reuse the docx's own
measure catalogue (M1–M14: cost → effect, on a 0–100-of-total-budget scale) as the
conversion rate. It's a deliberately simple, transparent stand-in for a real urban
model — every number the UI shows next to a projected indicator can be traced back
to one of these anchors. See the "Method" note surfaced alongside the Score tab.
"""
from .models import District
from .open_data import district_of

WEIGHTS = {"t1": 0.10, "t2": 0.10, "e1": 0.09, "e2": 0.11, "s1": 0.11, "s2": 0.11, "b1": 0.09, "b2": 0.09, "c1": 0.10, "c2": 0.10}
INDICATORS = list(WEIGHTS)
LABELS = {
    "t1": "Road congestion relief", "t2": "Public transport accessibility", "e1": "Green space",
    "e2": "Air quality", "s1": "Schools & kindergartens", "s2": "Clinics & primary healthcare",
    "b1": "Street safety", "b2": "Road safety", "c1": "Utility reliability", "c2": "Speed of resolving requests",
}
CATEGORY = {"t1": "Transport", "t2": "Transport", "e1": "Environment", "e2": "Environment", "s1": "Social services",
           "s2": "Social services", "b1": "Safety", "b2": "Safety", "c1": "Services", "c2": "Services"}
CRITICAL = 40

# Measure anchors from the docx catalogue: cost is in "budget points" (the docx's 100-point
# scale represents the whole city budget spread over ~5 measures); we convert real tenge to
# that scale via kzt_per_point = total_money_budget_kzt / 100.
M1_BUS_LANES = {"cost": 18, "t1": 6, "t2": 9}          # dedicated bus lanes (spend: new bus stops + rail stations)
M4_PARK = {"cost": 15, "e1": 12, "e2": 3, "b1": 2}     # park / public garden (spend: new trees)
M7_SCHOOL = {"cost": 24, "s1": 16}                     # school/kindergarten (spend: new school + kindergarten builds)
M10_LIGHTING = {"cost": 12, "b1": 12, "b2": 2}         # lighting & cameras (spend: new lamps + CCTV)
M11_CROSSINGS = {"cost": 10, "b2": 12}                 # safe crossings (spend: new speed cameras)
M13_UTILITIES = {"cost": 28, "c1": 18, "e2": 2}        # heating/water network modernisation (spend: city-services fixes)


def _clip(v):
    return max(0.0, min(100.0, v))


def _apply(effects, spend_kzt, unit_kzt, into):
    if unit_kzt <= 0 or spend_kzt <= 0:
        return
    ratio = spend_kzt / unit_kzt / effects["cost"]
    for key, delta in effects.items():
        if key == "cost":
            continue
        into[key] = into.get(key, 0) + ratio * delta


def _cost_row(costs, key, count):
    c = costs.get(key, {})
    return count * (c.get("setup_kzt", 0) if isinstance(c, dict) else 0)


def project_indicators(districts_by_name, unit_kzt, transport=None, greenery=None, safety=None, education=None, city=None):
    """Per-district raw effect deltas {district_name: {indicator: delta}}, from each domain's scenario."""
    effects = {name: {} for name in districts_by_name}

    def district_for(lon, lat):
        d = district_of(lon, lat, [
            {"name": n, "bbox": x.bbox, "outer": x.outline, "inner": x.holes} for n, x in districts_by_name.items()
        ])
        return d["name"] if d else None

    # Transport: new bus stops + rail stations placed on the map, by district.
    if transport:
        costs = transport.get("costs", {})
        spend = {n: 0 for n in districts_by_name}
        for s in transport.get("new_stops", []):
            n = district_for(s.get("lon"), s.get("lat"))
            if n:
                spend[n] += costs.get("bus_stop" if s.get("kind") == "bus" else "rail_station", {}).get("setup_kzt", 0)
        for n, kzt in spend.items():
            _apply(M1_BUS_LANES, kzt, unit_kzt, effects[n])

    # Greenery: trees dropped on the map or mass-planted in a district.
    if greenery:
        costs = greenery.get("costs", {})
        per_tree = costs.get("sapling_kzt", 0) + costs.get("planting_kzt", 0)
        spend = {n: 0 for n in districts_by_name}
        for p in greenery.get("plantings", []):
            count = p.get("count", 0)
            n = p.get("district") if p.get("kind") == "mass" else district_for(p.get("lon"), p.get("lat"))
            if n in spend:
                spend[n] += count * per_tree
        for n, kzt in spend.items():
            _apply(M4_PARK, kzt, unit_kzt, effects[n])

    # Safety: lamps/CCTV (street safety) and speed cameras (road safety), placed or bulk-added.
    if safety:
        costs = safety.get("costs", {})
        light_spend = {n: 0 for n in districts_by_name}
        road_spend = {n: 0 for n in districts_by_name}
        for p in safety.get("placements", []):
            n = district_for(p.get("lon"), p.get("lat"))
            if n in light_spend:
                cost = costs.get(p["kind"], {}).get("setup_kzt", 0)
                (road_spend if p["kind"] == "speed_camera" else light_spend)[n] += cost
        for n, added in (safety.get("added") or {}).items():
            if n not in light_spend:
                continue
            light_spend[n] += (added.get("lamp", 0) * costs.get("lamp", {}).get("setup_kzt", 0)
                               + added.get("cctv", 0) * costs.get("cctv", {}).get("setup_kzt", 0))
            road_spend[n] += added.get("speed_camera", 0) * costs.get("speed_camera", {}).get("setup_kzt", 0)
        for n in districts_by_name:
            _apply(M10_LIGHTING, light_spend[n], unit_kzt, effects[n])
            _apply(M11_CROSSINGS, road_spend[n], unit_kzt, effects[n])

    # Social services: new schools + kindergartens, placed or bulk-added.
    if education:
        costs = education.get("costs", {}).get("build", {})
        spend = {n: 0 for n in districts_by_name}
        for p in education.get("placements", []):
            n = district_for(p.get("lon"), p.get("lat"))
            if n in spend:
                spend[n] += costs.get(p["kind"], 0)
        for n, added in (education.get("added") or {}).items():
            if n in spend:
                spend[n] += added.get("school", 0) * costs.get("school", 0) + added.get("kindergarten", 0) * costs.get("kindergarten", 0)
        for n, kzt in spend.items():
            _apply(M7_SCHOOL, kzt, unit_kzt, effects[n])

    # City services: water pipe / electrical wiring / heater fixes, placed on the map.
    if city:
        costs = city.get("costs", {})
        spend = {n: 0 for n in districts_by_name}
        for f in city.get("fixes", []):
            n = district_for(f.get("lon"), f.get("lat"))
            if n in spend:
                spend[n] += costs.get(f["kind"], {}).get("setup_kzt", 0)
        for n, kzt in spend.items():
            _apply(M13_UTILITIES, kzt, unit_kzt, effects[n])

    return effects


def score(districts_by_name, indicators_after=None):
    """Given {name: {indicator: value}} (defaults to each District's own baseline), compute
    D_d per district, D_avg, min(D_d), N_crit and the Final Score — over the 5 docx districts."""
    rows = {}
    n_crit = 0
    for name, d in districts_by_name.items():
        if d.docx_population_share is None:
            continue  # Saraishyq — not in the docx dataset
        values = (indicators_after or {}).get(name) or {k: getattr(d, {
            "t1": "t1_congestion", "t2": "t2_accessibility", "e1": "e1_green", "e2": "e2_air", "s1": "s1_schools",
            "s2": "s2_clinics", "b1": "b1_street_safety", "b2": "b2_road_safety", "c1": "c1_utilities", "c2": "c2_requests",
        }[k]) for k in INDICATORS}
        d_d = sum(WEIGHTS[k] * values[k] for k in INDICATORS)
        n_crit += sum(1 for k in INDICATORS if values[k] < CRITICAL)
        rows[name] = {"values": values, "D_d": d_d, "share": d.docx_population_share}
    d_avg = sum(r["D_d"] * r["share"] for r in rows.values())
    min_d = min(r["D_d"] for r in rows.values())
    final = 0.7 * d_avg + 0.3 * min_d - 1.0 * n_crit
    return {"districts": rows, "D_avg": d_avg, "min_D": min_d, "N_crit": n_crit, "score": final}


def apply_effects(districts, effects):
    """{name: {indicator: baseline+delta, clipped}} for every district (all 10, even where docx has no baseline)."""
    field = {"t1": "t1_congestion", "t2": "t2_accessibility", "e1": "e1_green", "e2": "e2_air", "s1": "s1_schools",
            "s2": "s2_clinics", "b1": "b1_street_safety", "b2": "b2_road_safety", "c1": "c1_utilities", "c2": "c2_requests"}
    out = {}
    for d in districts:
        base = {k: getattr(d, field[k]) for k in INDICATORS}
        delta = effects.get(d.name, {})
        out[d.name] = {k: (None if base[k] is None else _clip(base[k] + delta.get(k, 0))) for k in INDICATORS}
    return out
