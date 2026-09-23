"""Builds the transport-tab data from open sources and stores it in Postgres.

Sources (all open, credited on the page):
  * Bus routes, stops & timings — Mansurova et al. (2025), "From Raw GPS to GTFS: A
    Real-World Open Dataset for Bus Travel Time Prediction", Zenodo,
    doi:10.5281/zenodo.15769359 (CC BY 4.0). Routes 10, 12 and 46, Jul–Sep 2024.
  * City-wide bus stops, rail/LRT stations, district boundaries and buildings —
    © OpenStreetMap contributors (ODbL), via the Overpass API.
  * District population (1 July 2026) — qazatlas.kz/ru/city/astana.
  * District transport indicators T1/T2 — District_Dataset_EN.docx.

Run with:  python backend/manage.py import_transport   (downloads are cached in data/raw/)
"""
import csv
import io
import json
import math
import statistics
import time
import zipfile
from collections import Counter, defaultdict
from pathlib import Path

import requests
from django.conf import settings
from django.db import transaction

from .models import BusRoute, BusStop, District, PopulationCell, RailStation

RAW = Path(settings.REPO_ROOT) / "data" / "raw"
GTFS_URL = "https://zenodo.org/api/records/15769359/files/gtfs_data.zip/content"
OVERPASS = "https://overpass-api.de/api/interpreter"
USER_AGENT = "hackalem-astana-budget-planner/1.0 (civic planning prototype)"

# OSM relation id → display data. Population: qazatlas.kz (1 July 2026).
# T1/T2: District_Dataset_EN.docx baseline (0–100, higher is better); Saraishyq is not in it.
DISTRICTS = {
    3486954: dict(name="Saryarqa", name_kk="Сарыарқа", population=349_923, share=20.8, yoy=-0.3, t1=50, t2=70, color="#B39DDB"),
    3479876: dict(name="Yesil", name_kk="Есіл", population=333_348, share=19.8, yoy=9.2, t1=45, t2=62, color="#4FC3C6"),
    20593940: dict(name="Nura", name_kk="Нұра", population=328_785, share=19.5, yoy=20.5, t1=55, t2=40, color="#81C784"),
    3482819: dict(name="Almaty", name_kk="Алматы", population=256_353, share=15.2, yoy=-39.6, t1=40, t2=75, color="#F6B26B"),
    8593081: dict(name="Baikonyr", name_kk="Байқоңыр", population=213_554, share=12.7, yoy=-4.0, t1=52, t2=68, color="#F48FB1"),
    19733918: dict(name="Saraishyq", name_kk="Сарайшық", population=200_758, share=11.9, yoy=None, t1=None, t2=None, color="#E6C84F"),
}
ROUTE_COLORS = {"10": "#E4572E", "12": "#3E7CB1", "46": "#8E44AD"}

# Buildings that are not homes — excluded from the population model.
NON_RESIDENTIAL = {
    "retail", "industrial", "commercial", "school", "office", "garages", "garage", "roof", "kindergarten",
    "service", "hangar", "hospital", "university", "shed", "hotel", "train_station", "government",
    "guardhouse", "warehouse", "church", "mosque", "public", "civic", "transportation", "construction",
    "kiosk", "parking", "sports_centre", "stadium", "college", "clinic", "fire_station", "greenhouse",
    "farm_auxiliary", "toilets", "supermarket", "barn", "container", "ruins", "bunker", "static_caravan",
}
CELL_DEG_LAT = 0.0018  # ≈200 m
CELL_DEG_LON = 0.0029  # ≈200 m at 51° N


# ---------------------------------------------------------------------------
# Downloads (cached)
# ---------------------------------------------------------------------------
def _cached(name, fetch, log):
    RAW.mkdir(parents=True, exist_ok=True)
    path = RAW / name
    if path.exists():
        log(f"  using cached {path.relative_to(settings.REPO_ROOT)}")
        return path.read_bytes()
    log(f"  downloading {name} …")
    data = fetch()
    path.write_bytes(data)
    return data


def _overpass(query, log, name):
    def fetch():
        for attempt in range(4):
            res = requests.post(OVERPASS, data={"data": query}, headers={"User-Agent": USER_AGENT}, timeout=320)
            if res.status_code == 200 and res.content.lstrip().startswith(b"{"):
                return res.content
            log(f"    Overpass busy (HTTP {res.status_code}), retrying …")
            time.sleep(20 * (attempt + 1))
        raise RuntimeError(f"Overpass query for {name} kept failing; try again later.")

    return json.loads(_cached(name, fetch, log))["elements"]


# ---------------------------------------------------------------------------
# Geometry helpers
# ---------------------------------------------------------------------------
def _stitch_rings(ways):
    """Join OSM way segments (lists of [lon, lat]) into closed rings."""
    segments = [list(w) for w in ways if len(w) > 1]
    rings = []
    while segments:
        ring = segments.pop(0)
        changed = True
        while ring[0] != ring[-1] and changed:
            changed = False
            for i, seg in enumerate(segments):
                if seg[0] == ring[-1]:
                    ring += seg[1:]
                elif seg[-1] == ring[-1]:
                    ring += seg[::-1][1:]
                elif seg[-1] == ring[0]:
                    ring = seg[:-1] + ring
                elif seg[0] == ring[0]:
                    ring = seg[::-1][:-1] + ring
                else:
                    continue
                segments.pop(i)
                changed = True
                break
        if len(ring) >= 4:
            rings.append(ring if ring[0] == ring[-1] else ring + [ring[0]])
    return rings


def _in_ring(lon, lat, ring):
    inside = False
    j = len(ring) - 1
    for i in range(len(ring)):
        xi, yi = ring[i]
        xj, yj = ring[j]
        if (yi > lat) != (yj > lat) and lon < (xj - xi) * (lat - yi) / (yj - yi) + xi:
            inside = not inside
        j = i
    return inside


def _in_district(lon, lat, d):
    minx, miny, maxx, maxy = d["bbox"]
    if not (minx <= lon <= maxx and miny <= lat <= maxy):
        return False
    return any(_in_ring(lon, lat, r) for r in d["outer"]) and not any(_in_ring(lon, lat, r) for r in d["inner"])


def _ring_area_m2(ring):
    lat0 = math.radians(sum(p[1] for p in ring) / len(ring))
    kx, ky = 111_320 * math.cos(lat0), 110_540
    area = 0.0
    for (x1, y1), (x2, y2) in zip(ring, ring[1:]):
        area += (x1 * kx) * (y2 * ky) - (x2 * kx) * (y1 * ky)
    return abs(area) / 2


def _metres(lon1, lat1, lon2, lat2):
    kx = 111_320 * math.cos(math.radians((lat1 + lat2) / 2))
    return math.hypot((lon2 - lon1) * kx, (lat2 - lat1) * 110_540)


def _simplify(ring, tolerance=0.0004):
    """Drop points closer than ~40 m to the previous kept point (keeps payloads small)."""
    out = [ring[0]]
    for p in ring[1:-1]:
        if abs(p[0] - out[-1][0]) > tolerance or abs(p[1] - out[-1][1]) > tolerance:
            out.append(p)
    out.append(ring[-1])
    return out


# ---------------------------------------------------------------------------
# Builders
# ---------------------------------------------------------------------------
def build_districts(log):
    ids = ",".join(map(str, DISTRICTS))
    elements = _overpass(f"[out:json][timeout:120];relation(id:{ids});out geom;", log, "osm_districts.json")
    districts = []
    for rel in elements:
        meta = DISTRICTS[rel["id"]]
        ways = defaultdict(list)
        for m in rel["members"]:
            if m["type"] == "way" and "geometry" in m:
                ways[m.get("role") or "outer"].append([[round(p["lon"], 6), round(p["lat"], 6)] for p in m["geometry"]])
        outer, inner = _stitch_rings(ways["outer"]), _stitch_rings(ways["inner"])
        pts = [p for r in outer for p in r]
        area = sum(_ring_area_m2(r) for r in outer) - sum(_ring_area_m2(r) for r in inner)
        districts.append({
            **meta,
            "osm_id": rel["id"],
            "outer": outer,
            "inner": inner,
            "bbox": [min(p[0] for p in pts), min(p[1] for p in pts), max(p[0] for p in pts), max(p[1] for p in pts)],
            "area_km2": round(area / 1e6, 1),
        })
        log(f"  {meta['name']}: {len(outer)} ring(s), {area / 1e6:.1f} km²")
    return districts


def district_of(lon, lat, districts):
    for d in districts:
        if _in_district(lon, lat, d):
            return d
    return None


def build_gtfs(log):
    raw = _cached("zenodo_15769359_gtfs.zip", lambda: requests.get(GTFS_URL, timeout=300).content, log)
    zf = zipfile.ZipFile(io.BytesIO(raw))

    def table(name):
        member = next(n for n in zf.namelist() if n.endswith(name))
        text = zf.read(member).decode("cp1252")  # the dataset's text files are Windows-1252
        return list(csv.DictReader(io.StringIO(text.lstrip("﻿")), delimiter="\t"))

    def sec(t):
        h, m, s = map(int, t.split(":"))
        return h * 3600 + m * 60 + s

    stops = {s["stop_id"]: s for s in table("stops.txt")}
    routes = {r["route_id"]: r for r in table("routes.txt")}
    trips = table("trips.txt")
    trip_route = {t["trip_id"]: t for t in trips}

    # Ordered stops per trip → the most common sequence per route+direction is the route shape.
    seqs = defaultdict(list)
    for st in table("stop_times.txt"):
        seqs[st["trip_id"]].append((int(st["stop_sequence"]), st["stop_id"]))
    shapes = defaultdict(Counter)
    for trip_id, items in seqs.items():
        t = trip_route.get(trip_id)
        if t:
            shapes[(t["route_id"], t["direction_id"])][tuple(sid for _, sid in sorted(items))] += 1

    out = []
    for rid, r in routes.items():
        rtrips = [t for t in trips if t["route_id"] == rid]
        by_day = defaultdict(list)
        for t in rtrips:
            by_day[t["service_id"]].append(t)
        peak, all_gaps = [], []
        for day in by_day.values():
            for direction in {t["direction_id"] for t in day}:
                deps = sorted(sec(t["start_time"]) for t in day if t["direction_id"] == direction)
                for a, b in zip(deps, deps[1:]):
                    gap = (b - a) / 60
                    if 0 < gap < 120:
                        all_gaps.append(gap)
                        if 7 * 3600 <= a < 9 * 3600:
                            peak.append(gap)
        durations = [(sec(t["end_time"]) - sec(t["start_time"])) / 60 for t in rtrips if sec(t["end_time"]) > sec(t["start_time"])]
        directions = {}
        for (route_id, direction), counter in shapes.items():
            if route_id == rid:
                seq = counter.most_common(1)[0][0]
                directions[direction] = [[round(float(stops[s]["stop_lon"]), 6), round(float(stops[s]["stop_lat"]), 6)] for s in seq]
        route_stop_ids = {s for (route_id, _), c in shapes.items() if route_id == rid for seq in c for s in seq}
        out.append({
            "short_name": r["route_short_name"],
            "long_name": r["route_long_name"].replace("–", "–"),
            "fleet": round(statistics.median(len({t["vehicle_id"] for t in d}) for d in by_day.values())),
            "vehicles_seen": len({t["vehicle_id"] for t in rtrips}),
            "trips_per_day": round(statistics.median(len(d) for d in by_day.values())),
            "peak_headway": round(statistics.median(peak), 1),
            "avg_headway": round(statistics.median(all_gaps), 1),
            "trip_minutes": round(statistics.median(durations)),
            "first_departure": min(t["start_time"] for t in rtrips)[:5],
            "last_departure": max(t["start_time"] for t in rtrips)[:5],
            "days_observed": len(by_day),
            "shape": directions,
            "stop_ids": route_stop_ids,
        })
        log(f"  route {r['route_short_name']}: {out[-1]['fleet']} buses/day, peak every {out[-1]['peak_headway']} min")
    return stops, out


def _bbox_param(districts):
    """Overpass bbox (south,west,north,east) covering every district."""
    return (f"{min(d['bbox'][1] for d in districts)},{min(d['bbox'][0] for d in districts)},"
            f"{max(d['bbox'][3] for d in districts)},{max(d['bbox'][2] for d in districts)}")


def build_bus_stops(districts, gtfs_stops, routes, log):
    bbox = _bbox_param(districts)
    elements = _overpass(
        f"[out:json][timeout:150][bbox:{bbox}];(node[highway=bus_stop];node[public_transport=platform][bus=yes];);out body;",
        log, "osm_bus_stops.json",
    )
    stops = []
    for e in elements:
        d = district_of(e["lon"], e["lat"], districts)
        if d:
            t = e.get("tags", {})
            stops.append({"name": t.get("name:en") or t.get("name") or "Bus stop", "lat": e["lat"], "lon": e["lon"],
                          "source": "osm", "district": d["name"], "routes": set()})

    # Attach Zenodo routes to the nearest OSM stop (≤40 m), or add the stop if OSM lacks it.
    stop_routes = defaultdict(set)
    for r in routes:
        for sid in r["stop_ids"]:
            stop_routes[sid].add(r["short_name"])
    added = 0
    for sid, s in gtfs_stops.items():
        lon, lat = float(s["stop_lon"]), float(s["stop_lat"])
        near = min(stops, key=lambda o: _metres(lon, lat, o["lon"], o["lat"]), default=None)
        if near and _metres(lon, lat, near["lon"], near["lat"]) <= 40:
            near["routes"] |= stop_routes[sid]
            continue
        d = district_of(lon, lat, districts)
        if d:
            stops.append({"name": s["stop_name"], "lat": lat, "lon": lon, "source": "zenodo", "district": d["name"],
                          "routes": set(stop_routes[sid])})
            added += 1
    log(f"  {len(stops)} bus stops ({added} only in the Zenodo data)")
    return stops


def build_rail(districts, log):
    bbox = _bbox_param(districts)
    elements = _overpass(
        f'[out:json][timeout:120][bbox:{bbox}];nwr["railway"~"^(station|halt)$"];out center tags;', log, "osm_rail.json"
    )
    seen, stations = set(), []
    for e in elements:
        t = e.get("tags", {})
        name = t.get("name", "")
        if "айрығы" in name:  # railway junction — freight, not a passenger station
            continue
        kind = "lrt" if t.get("station") == "light_rail" or t.get("light_rail") == "yes" else "rail"
        lat, lon = e.get("lat") or e["center"]["lat"], e.get("lon") or e["center"]["lon"]
        # Stations are often mapped twice (a point and an outline) with different spellings.
        if any(k == kind and _metres(lon, lat, x, y) < 150 for k, x, y in seen):
            continue
        seen.add((kind, lon, lat))
        d = district_of(lon, lat, districts)
        if not d:
            continue  # the bbox reaches past the city limits
        stations.append({"name": name, "name_en": t.get("name:en") or name, "kind": kind, "lat": lat, "lon": lon,
                         "district": d["name"]})
    log(f"  {sum(s['kind'] == 'rail' for s in stations)} rail + {sum(s['kind'] == 'lrt' for s in stations)} LRT stations")
    return stations


def build_population(districts, log):
    bbox = _bbox_param(districts)
    elements = _overpass(
        f"[out:json][timeout:280][maxsize:536870912][bbox:{bbox}];way[building];out tags geom;", log, "osm_buildings.json"
    )
    # Weight = residential floor area (footprint × floors), aggregated into ~200 m cells.
    weights = defaultdict(float)
    cell_district = {}
    used = 0
    for e in elements:
        t = e.get("tags", {})
        kind = t.get("building", "yes")
        geom = e.get("geometry")
        if kind in NON_RESIDENTIAL or not geom or len(geom) < 4:
            continue
        ring = [[p["lon"], p["lat"]] for p in geom]
        area = _ring_area_m2(ring)
        if area < 30:
            continue
        try:
            levels = float(t.get("building:levels", "").split(";")[0])
        except ValueError:
            levels = 5 if kind in ("apartments", "residential", "dormitory") or area > 600 else 1
        lon = sum(p[0] for p in ring) / len(ring)
        lat = sum(p[1] for p in ring) / len(ring)
        key = (round(lon / CELL_DEG_LON), round(lat / CELL_DEG_LAT))
        if key not in cell_district:
            d = district_of(key[0] * CELL_DEG_LON, key[1] * CELL_DEG_LAT, districts) or district_of(lon, lat, districts)
            cell_district[key] = d["name"] if d else None
        if cell_district[key]:
            weights[key] += area * max(1, min(levels, 40))
            used += 1
    totals = defaultdict(float)
    for key, w in weights.items():
        totals[cell_district[key]] += w
    pop_by_name = {d["name"]: d["population"] for d in districts}
    cells = [
        {"lon": round(k[0] * CELL_DEG_LON, 5), "lat": round(k[1] * CELL_DEG_LAT, 5), "district": cell_district[k],
         "population": w / totals[cell_district[k]] * pop_by_name[cell_district[k]]}
        for k, w in weights.items()
    ]
    log(f"  {used:,} residential buildings → {len(cells):,} population cells")
    return cells


@transaction.atomic
def save(districts, stops, stations, routes, cells):
    for model in (PopulationCell, BusStop, RailStation, BusRoute, District):
        model.objects.all().delete()
    by_name = {}
    for d in districts:
        by_name[d["name"]] = District.objects.create(
            osm_id=d["osm_id"], name=d["name"], name_kk=d["name_kk"], population=d["population"],
            population_share=d["share"], population_change=d["yoy"], t1_congestion=d["t1"], t2_accessibility=d["t2"],
            color=d["color"], area_km2=d["area_km2"], bbox=d["bbox"],
            outline=[_simplify(r) for r in d["outer"]], holes=[_simplify(r) for r in d["inner"]],
        )
    BusStop.objects.bulk_create([
        BusStop(name=s["name"][:120], lat=s["lat"], lon=s["lon"], source=s["source"], district=by_name[s["district"]],
                routes=sorted(s["routes"])) for s in stops
    ])
    RailStation.objects.bulk_create([
        RailStation(name=s["name"][:120], name_en=s["name_en"][:120], kind=s["kind"], lat=s["lat"], lon=s["lon"],
                    district=by_name.get(s["district"])) for s in stations
    ])
    for r in routes:
        BusRoute.objects.create(**{k: v for k, v in r.items() if k != "stop_ids"}, color=ROUTE_COLORS.get(r["short_name"], "#555"))
    PopulationCell.objects.bulk_create([
        PopulationCell(lat=c["lat"], lon=c["lon"], population=round(c["population"], 2), district=by_name[c["district"]])
        for c in cells
    ], batch_size=2000)


def run(log=print):
    log("Districts (OpenStreetMap)")
    districts = build_districts(log)
    log("Bus routes & timings (Zenodo GTFS)")
    gtfs_stops, routes = build_gtfs(log)
    log("Bus stops (OpenStreetMap + Zenodo)")
    stops = build_bus_stops(districts, gtfs_stops, routes, log)
    log("Rail & LRT stations (OpenStreetMap)")
    stations = build_rail(districts, log)
    log("Population model (OpenStreetMap buildings × qazatlas.kz)")
    cells = build_population(districts, log)
    save(districts, stops, stations, routes, cells)
    log("Saved to PostgreSQL.")
