"""Builds the dashboard's reference data from open sources and stores it in Postgres.

Sources (all open, credited on the page):
  * Bus routes, stops & timings — Mansurova et al. (2025), "From Raw GPS to GTFS: A
    Real-World Open Dataset for Bus Travel Time Prediction", Zenodo,
    doi:10.5281/zenodo.15769359 (CC BY 4.0). Routes 10, 12 and 46, Jul–Sep 2024.
  * City-wide bus stops, rail/LRT stations, district boundaries, buildings, green
    areas (parks, gardens, grass, forest) and mapped trees —
    © OpenStreetMap contributors (ODbL), via the Overpass API.
  * District population (1 July 2026) — qazatlas.kz/ru/city/astana.
  * District indicators (T1–C2) and profiles — District_Dataset_EN.docx.
  * Fire stations, police departments and local police posts — 2GIS directory (catalog API).
  * Official bus-stop counts — Astana GIS centre open geoportal (gis.esaulet.kz).
  * National road-safety figures — ATO Kazakhstan Road Safety Profile 2025 (WHO 2021 data).
  * Schools & kindergartens — 2GIS directory; births by year & district — qazatlas.kz (Bureau of
    National Statistics); school/kindergarten capacity and pay — Astana education department and
    Ministry of Enlightenment figures as reported by inform.kz, bilim.expert, zakon.kz.

Two commands:
  python backend/manage.py build_open_data   downloads (cached in data/raw/), rebuilds the
                                              tables and writes core/fixtures/open_data.json.gz
  python backend/manage.py load_open_data    loads that committed file — offline, seconds;
                                              `npm start` runs it whenever the tables are empty
"""
import csv
import gzip
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
from django.utils import timezone

from .models import (BirthYear, BusRoute, BusStop, District, EducationPlace, GreenArea, GreenCell, PopulationCell,
                     RailStation, ReferenceFigure, SafetyPlace, Tree)

RAW = Path(settings.REPO_ROOT) / "data" / "raw"
FIXTURE = Path(__file__).resolve().parent / "fixtures" / "open_data.json.gz"
GTFS_URL = "https://zenodo.org/api/records/15769359/files/gtfs_data.zip/content"
# Main Overpass server first, then a public mirror (the main one is often overloaded).
OVERPASS_HOSTS = ["https://overpass-api.de/api/interpreter", "https://maps.mail.ru/osm/tools/overpass/api/interpreter"]
USER_AGENT = "hackalem-astana-budget-planner/1.0 (civic planning prototype)"

# OSM relation id → display data. Population: qazatlas.kz (1 July 2026).
# T1/T2: District_Dataset_EN.docx baseline (0–100, higher is better); Saraishyq is not in it.
DISTRICTS = {
    3486954: dict(name="Saryarqa", name_kk="Сарыарқа", population=349_923, share=20.8, yoy=-0.3, color="#B39DDB",
                  t1=50, t2=70, e1=42, e2=40, s1=62, s2=68, b1=58, b2=55, c1=45, c2=55,
                  profile="Smog from the private housing sector and insufficient greenery."),
    3479876: dict(name="Yesil", name_kk="Есіл", population=333_348, share=19.8, yoy=9.2, color="#4FC3C6",
                  t1=45, t2=62, e1=68, e2=72, s1=48, s2=55, b1=78, b2=60, c1=75, c2=70,
                  profile="Affluent, but affected by traffic congestion on bridges and overcrowded schools."),
    20593940: dict(name="Nura", name_kk="Нұра", population=328_785, share=19.5, yoy=20.5, color="#81C784",
                   t1=55, t2=40, e1=45, e2=65, s1=38, s2=35, b1=55, b2=50, c1=60, c2=50,
                   profile="The main lagging district in social services and transport."),
    3482819: dict(name="Almaty", name_kk="Алматы", population=256_353, share=15.2, yoy=-39.6, color="#F6B26B",
                  t1=40, t2=75, e1=50, e2=55, s1=60, s2=65, b1=62, b2=52, c1=50, c2=60,
                  profile="Aging utility infrastructure and traffic congestion."),
    8593081: dict(name="Baikonyr", name_kk="Байқоңыр", population=213_554, share=12.7, yoy=-4.0, color="#F48FB1",
                  t1=52, t2=68, e1=55, e2=50, s1=58, s2=60, b1=52, b2=58, c1=55, c2=58,
                  profile="Average overall, with no pronounced imbalances."),
    19733918: dict(name="Saraishyq", name_kk="Сарайшық", population=200_758, share=11.9, yoy=None, color="#E6C84F",
                   t1=None, t2=None, e1=None, e2=None, s1=None, s2=None, b1=None, b2=None, c1=None, c2=None,
                   profile="Created in 2024 — not covered by the district dataset."),
}
INDICATORS = ["t1", "t2", "e1", "e2", "s1", "s2", "b1", "b2", "c1", "c2"]

# Births in Astana by year — Bureau of National Statistics via qazatlas.kz/ru/city/astana/rozhdaemost.
# 2025 is summed from the monthly figures on the same page (Jan–Jul 15,157 + Aug–Dec 11,240).
BIRTHS = {2000: 4465, 2001: 4750, 2002: 5585, 2003: 6449, 2004: 7990, 2005: 9042, 2006: 10026, 2007: 12511, 2008: 15054,
          2009: 15153, 2010: 17345, 2011: 17865, 2012: 19463, 2013: 21896, 2014: 24082, 2015: 26134, 2016: 27845,
          2017: 28276, 2018: 29181, 2019: 28736, 2020: 29565, 2021: 31395, 2022: 30302, 2023: 29415, 2024: 28526,
          2025: 26397}
BIRTHS_ESTIMATED = {2025}
# 2024 births by district (qazatlas district pages). Saraishyq was split from Almaty in 2024, so the
# Almaty figure (9,257) is shared between the two by population.
DISTRICT_BIRTHS_2024 = {"Saryarqa": 5695, "Yesil": 6840, "Nura": 3684, "Baikonyr": 3050,
                        "Almaty": round(9257 * 256_353 / (256_353 + 200_758)), "Saraishyq": round(9257 * 200_758 / (256_353 + 200_758))}
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

# Green space. "park" = everyday green (parks, gardens, lawns, meadows); "forest" =
# woodland and scrub, which in Astana is mostly the planted green belt at the edge of town.
GREEN_KINDS = {
    "park": "park", "garden": "park", "nature_reserve": "forest", "recreation_ground": "park",
    "grass": "park", "meadow": "park", "village_green": "park",
    "forest": "forest", "wood": "forest", "scrub": "forest",
}
SAMPLE_DEG_LAT = 0.00036  # ≈40 m sample grid used to measure green area without double counting
SAMPLE_DEG_LON = 0.00057


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


def _overpass_fetch(query, log, name):
    for attempt in range(4):
        for host in OVERPASS_HOSTS:
            try:
                res = requests.post(host, data={"data": query}, headers={"User-Agent": USER_AGENT}, timeout=320)
            except requests.RequestException as exc:
                log(f"    {host.split('/')[2]} unreachable ({exc.__class__.__name__}), trying next …")
                continue
            if res.status_code == 200 and res.content.lstrip().startswith(b"{"):
                return res.content
            log(f"    {host.split('/')[2]} busy (HTTP {res.status_code}), trying next …")
        time.sleep(20 * (attempt + 1))
    raise RuntimeError(f"Overpass query for {name} kept failing; try again later.")


def _overpass(query, log, name):
    return json.loads(_cached(name, lambda: _overpass_fetch(query, log, name), log))["elements"]


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


def _cell_key(lon, lat):
    return (round(lon / CELL_DEG_LON), round(lat / CELL_DEG_LAT))


def _scanline_samples(rings):
    """Yield (ix, iy) sample-grid indices inside the rings (even-odd rule, so holes work)."""
    ys = [p[1] for r in rings for p in r]
    iy0, iy1 = math.floor(min(ys) / SAMPLE_DEG_LAT), math.ceil(max(ys) / SAMPLE_DEG_LAT)
    edges = [(r[i], r[i + 1]) for r in rings for i in range(len(r) - 1)]
    for iy in range(iy0, iy1 + 1):
        y = (iy + 0.5) * SAMPLE_DEG_LAT
        xs = sorted(x1 + (y - y1) * (x2 - x1) / (y2 - y1) for (x1, y1), (x2, y2) in edges if (y1 > y) != (y2 > y))
        for a, b in zip(xs[::2], xs[1::2]):
            for ix in range(math.ceil(a / SAMPLE_DEG_LON - 0.5), math.floor(b / SAMPLE_DEG_LON - 0.5) + 1):
                yield ix, iy


def build_green(districts, log):
    elements = _overpass(
        f"[out:json][timeout:250][maxsize:536870912][bbox:{_bbox_param(districts)}];"
        '(way[leisure~"^(park|garden|nature_reserve)$"];relation[leisure~"^(park|garden|nature_reserve)$"];'
        'way[landuse~"^(grass|forest|meadow|village_green|recreation_ground)$"];'
        'relation[landuse~"^(grass|forest|meadow|village_green|recreation_ground)$"];'
        'way[natural~"^(wood|scrub)$"];relation[natural~"^(wood|scrub)$"];);out tags geom;',
        log, "osm_green.json",
    )
    sample_area = SAMPLE_DEG_LON * 111_320 * math.cos(math.radians(51.15)) * SAMPLE_DEG_LAT * 110_540
    samples = {}      # (ix, iy) -> "park" | "forest"  (union: overlaps count once, parks win)
    extra = defaultdict(lambda: {"park": 0.0, "forest": 0.0})  # tiny polygons that no sample hits
    cell_district = {}
    shapes = []

    def district_for_cell(key, lon, lat):
        if key not in cell_district:
            d = district_of(key[0] * CELL_DEG_LON, key[1] * CELL_DEG_LAT, districts) or district_of(lon, lat, districts)
            cell_district[key] = d["name"] if d else None
        return cell_district[key]

    for e in elements:
        t = e.get("tags", {})
        kind = next((t[k] for k in ("leisure", "landuse", "natural") if t.get(k) in GREEN_KINDS), None)
        if not kind:
            continue
        if e["type"] == "way" and e.get("geometry"):
            rings = [[[p["lon"], p["lat"]] for p in e["geometry"]]]
        elif e.get("members"):
            rings = _stitch_rings([[[p["lon"], p["lat"]] for p in m["geometry"]] for m in e["members"]
                                   if m.get("role") in ("outer", "") and m.get("geometry")])
        else:
            continue
        rings = [r for r in rings if len(r) >= 4 and r[0] == r[-1]]
        if not rings:
            continue
        category = GREEN_KINDS[kind]
        hit = False
        for ix, iy in _scanline_samples(rings):
            hit = True
            if samples.get((ix, iy)) != "park":
                samples[(ix, iy)] = category
        area = sum(_ring_area_m2(r) for r in rings)
        cx = sum(p[0] for p in rings[0]) / len(rings[0])
        cy = sum(p[1] for p in rings[0]) / len(rings[0])
        if not hit:
            extra[_cell_key(cx, cy)][category] += area
        d = district_of(cx, cy, districts)
        if d and area >= 200:
            shapes.append({"kind": kind, "category": category, "name": t.get("name:en") or t.get("name", ""),
                           "area_m2": round(area), "district": d["name"],
                           "rings": [_simplify(r, 0.00008) for r in rings]})

    cells = defaultdict(lambda: {"park": 0.0, "forest": 0.0})
    for (ix, iy), category in samples.items():
        lon, lat = (ix + 0.5) * SAMPLE_DEG_LON, (iy + 0.5) * SAMPLE_DEG_LAT
        cells[_cell_key(lon, lat)][category] += sample_area
    for key, add in extra.items():
        for c, a in add.items():
            cells[key][c] += a
    out = []
    for key, v in cells.items():
        name = district_for_cell(key, key[0] * CELL_DEG_LON, key[1] * CELL_DEG_LAT)
        if name:
            out.append({"lon": round(key[0] * CELL_DEG_LON, 5), "lat": round(key[1] * CELL_DEG_LAT, 5),
                        "park": round(v["park"]), "forest": round(v["forest"]), "district": name})
    total = defaultdict(float)
    for c in out:
        total[c["district"]] += c["park"] + c["forest"]
    log(f"  {len(shapes):,} green areas → {len(out):,} green cells; " +
        ", ".join(f"{k} {v / 1e6:.1f} km²" for k, v in sorted(total.items())))
    return out, shapes


def build_trees(districts, log):
    elements = _overpass(
        f"[out:json][timeout:150][bbox:{_bbox_param(districts)}];node[natural=tree];out body;", log, "osm_trees.json"
    )
    trees = []
    for e in elements:
        d = district_of(e["lon"], e["lat"], districts)
        if d:
            t = e.get("tags", {})
            trees.append({"lon": e["lon"], "lat": e["lat"], "district": d["name"],
                          "species": (t.get("species:en") or t.get("species") or t.get("genus") or "")[:80]})
    log(f"  {len(trees):,} mapped trees")
    return trees


DGIS_ITEMS = "https://catalog.api.2gis.com/3.0/items"
# 2GIS rubric ids → our kinds. (Found via the catalog API; see the command docstring.)
DGIS_RUBRICS = {"143": "fire_station", "51246": "police_station", "51249": "police_station", "53244": "police_post"}


def _dgis_search(rubric, box, key, log, depth=0):
    """All items of a rubric inside box=(w, s, e, n). The demo key returns ≤50 per query, so split if needed."""
    w, s_, e, n = box
    poly = f"POLYGON(({w} {s_},{e} {s_},{e} {n},{w} {n},{w} {s_}))"
    items, total = [], None
    for page in range(1, 6):
        res = requests.get(DGIS_ITEMS, params={"rubric_id": rubric, "polygon": poly, "page_size": 10, "page": page,
                                               "fields": "items.point,items.address", "key": key}, timeout=30).json()
        if res["meta"]["code"] == 404:
            return []
        if res["meta"]["code"] != 200:
            raise RuntimeError(f"2GIS catalog error: {res['meta'].get('error')}")
        total = res["result"]["total"]
        if total > 50 and depth < 6:
            mx, my = (w + e) / 2, (s_ + n) / 2
            out = []
            for sub in ((w, s_, mx, my), (mx, s_, e, my), (w, my, mx, n), (mx, my, e, n)):
                out += _dgis_search(rubric, sub, key, log, depth + 1)
            return out
        items += res["result"]["items"]
        if len(items) >= total:
            break
        time.sleep(0.2)
    return items


def build_safety(districts, log):
    key = settings.DGIS_API_KEY
    box = (min(d["bbox"][0] for d in districts), min(d["bbox"][1] for d in districts),
           max(d["bbox"][2] for d in districts), max(d["bbox"][3] for d in districts))

    def fetch():
        out, seen = [], set()
        for rubric, kind in DGIS_RUBRICS.items():
            for it in _dgis_search(rubric, box, key, log):
                if it["id"] in seen or "point" not in it:
                    continue
                seen.add(it["id"])
                out.append({"kind": kind, "name": it.get("name", ""), "address": it.get("address_name") or "",
                            "lon": it["point"]["lon"], "lat": it["point"]["lat"]})
        return json.dumps(out).encode()

    if not key and not (RAW / "dgis_safety.json").exists():
        raise RuntimeError("DGIS_API_KEY is not set in .env (needed to download stations from 2GIS).")
    places = []
    for x in json.loads(_cached("dgis_safety.json", fetch, log)):
        d = district_of(x["lon"], x["lat"], districts)
        if d:
            places.append({**x, "source": "2gis", "district": d["name"]})

    def fetch_osm():
        # Three small queries — one combined query regularly times out.
        head = f"[out:json][timeout:100][bbox:{_bbox_param(districts)}];"
        els = []
        for q in ("node[highway=street_lamp]", "node[highway=speed_camera]", "node[man_made=surveillance]"):
            els += json.loads(_overpass_fetch(f"{head}{q};out body;", log, q))["elements"]
        return json.dumps({"elements": els}).encode()

    elements = json.loads(_cached("osm_safety.json", fetch_osm, log))["elements"]
    for e in elements:
        t = e.get("tags", {})
        if t.get("highway") == "street_lamp":
            kind = "lamp"
        elif t.get("highway") == "speed_camera" or t.get("enforcement") in ("maxspeed", "traffic_signals", "average_speed"):
            kind = "speed_camera"
        elif t.get("man_made") == "surveillance" or t.get("surveillance:type"):
            kind = "cctv"
        else:
            continue
        d = district_of(e["lon"], e["lat"], districts)
        if d:
            places.append({"kind": kind, "name": t.get("name", ""), "lon": e["lon"], "lat": e["lat"], "source": "osm",
                           "district": d["name"]})
    counts = Counter(p["kind"] for p in places)
    log("  " + ", ".join(f"{k.replace('_', ' ')} {v}" for k, v in sorted(counts.items())))
    return places


# 2GIS education rubrics → (kind, subtype, public)
EDU_RUBRICS = {
    "245": ("school", "School", True), "683": ("school", "Gymnasium", True), "15287": ("school", "Lyceum", True),
    "15761": ("school", "School-kindergarten", True),
    "237": ("kindergarten", "State kindergarten", True), "110405": ("kindergarten", "Private kindergarten", False),
}


def build_education(districts, log):
    key = settings.DGIS_API_KEY
    box = (min(d["bbox"][0] for d in districts), min(d["bbox"][1] for d in districts),
           max(d["bbox"][2] for d in districts), max(d["bbox"][3] for d in districts))

    def fetch():
        out, seen = [], set()
        for rubric, (kind, subtype, public) in EDU_RUBRICS.items():
            items = _dgis_search(rubric, box, key, log)
            log(f"    {subtype}: {len(items)}")
            for it in items:
                if it["id"] in seen or "point" not in it:
                    continue
                seen.add(it["id"])
                out.append({"kind": kind, "subtype": subtype, "public": public, "name": it.get("name", ""),
                            "address": it.get("address_name") or "", "lon": it["point"]["lon"], "lat": it["point"]["lat"]})
        return json.dumps(out).encode()

    places = []
    for x in json.loads(_cached("dgis_education.json", fetch, log)):
        d = district_of(x["lon"], x["lat"], districts)
        if d:
            places.append({**x, "district": d["name"]})
    c = Counter((p["kind"], p["public"]) for p in places)
    log(f"  schools {c[('school', True)]}, state kindergartens {c[('kindergarten', True)]}, private kindergartens {c[('kindergarten', False)]}")
    return places


def education_references(today):
    schools = dict(source="Astana education department via Kazinform (inform.kz), 18 Jun 2026",
                   url="https://www.inform.kz/ru/shkolam-astani-nehvataet-174-tisyachi-uchenicheskih-mest-44823e2f",
                   data_year="2026", published="18 Jun 2026", retrieved=today)
    kg = dict(source="Astana preschool statistics via bilim.expert, 21 Dec 2025",
              url="https://www.bilim.expert/post/doshkolnoe-obrazovanie-v-astane-tekushchee-sostoyanie-i-perspektivy",
              data_year="2025", published="21 Dec 2025", retrieved=today)
    return [
        dict(key="schools_total", label="Schools operating in Astana", value=205, unit="schools", **schools),
        dict(key="school_pupils", label="Pupils in Astana schools", value=314_900, unit="pupils", **schools),
        dict(key="school_deficit", label="Shortage of school places", value=17_400, unit="places", **schools),
        dict(key="school_capacity", label="School places (pupils − shortage)", value=314_900 - 17_400, unit="places", **schools),
        dict(key="kg_orgs", label="Preschool organisations (99 state · 551 private · 3 departmental)", value=653, unit="organisations", **kg),
        dict(key="kg_capacity", label="Kindergarten places (design capacity)", value=69_501, unit="places", **kg),
        dict(key="kg_capacity_state", label="Kindergarten places — state", value=29_368, unit="places", **kg),
        dict(key="kg_capacity_private", label="Kindergarten places — private", value=39_298, unit="places", **kg),
        dict(key="kg_enrolled", label="Children in kindergartens", value=66_281, unit="children", **kg),
        dict(key="kg_coverage", label="Preschool coverage, ages 2–6 (official, all forms)", value=88.4, unit="%", **kg),
        dict(key="kg_queue", label="Children on the kindergarten waiting list", value=47_000, unit="children",
             source="Kazinform (inform.kz)", url="https://www.inform.kz/ru/ochered-vdetsadi-astani-previsila-47-tisyach-detey-35217c15",
             data_year="2025", published="2025", retrieved=today),
        dict(key="pay_teacher", label="Teacher pay, 1 full-time position (average)", value=393_000, unit="₸ / month",
             source="Ministry of Enlightenment via zakon.kz / Tengrinews, 4 Mar 2025",
             url="https://www.zakon.kz/obshestvo/6469188-zarplaty-uchiteley-v-kazakhstane-vyrosli-vdvoe-kakie-doplaty-i-stimuly-poluchayut-pedagogi.html",
             data_year="2025", published="4 Mar 2025", retrieved=today),
        dict(key="pay_kg_teacher", label="Kindergarten teacher pay, city average", value=258_000, unit="₸ / month",
             source="Ministry of Enlightenment via Kazinform (inform.kz)",
             url="https://www.inform.kz/ru/srednyaya-zarplata-vospitateley-sostavlyaet-250-270-tisyach-tenge-minprosvesheniya-rk-1c7285",
             data_year="2025", published="2025", retrieved=today),
        dict(key="pay_education_avg", label="Average wage, education sector (all staff)", value=271_982, unit="₸ / month",
             source="Bureau of National Statistics (Q3 2024) via MCFR", url="https://edu.mcfr.kz/question/5915-kak-nachislyat-zarabotnuyu-platu-tehnicheskomu-rabotniku-v-gosudarstvennoy-shkole-g-almaty",
             data_year="Q3 2024", published="2024", retrieved=today),
        dict(key="min_wage", label="Minimum wage (МЗП)", value=85_000, unit="₸ / month", source="Budget law 2026 via bcc.kz",
             url="https://www.bcc.kz/bcc-journal/mpr-mzp/", data_year="2026", published="2026", retrieved=today),
        dict(key="cost_school", label="Build cost — school for 1,200 pupils (Nura district)", value=7_000_000_000, unit="₸",
             source="Astana akimat via kapital.kz", url="https://kapital.kz/economic/151641/shkolu-na-1200-uchenicheskih-mest-postroyat-v-astane-za-schet-vozvrashennyh-aktivov.html",
             data_year="2025", published="2025", retrieved=today),
        dict(key="cost_kindergarten", label="Build cost — state kindergarten (Ministry estimate)", value=1_500_000_000, unit="₸",
             source="Ministry of Enlightenment via informburo.kz",
             url="https://informburo.kz/stati/skolko-stoit-poseshhenie-detskogo-sada-v-astane-i-kak-resit-problemu-nexvatki-mest",
             data_year="2025", published="2025", retrieved=today),
        dict(key="births_2024", label="Births in Astana", value=28_526, unit="babies", source="Bureau of National Statistics via qazatlas.kz",
             url="https://qazatlas.kz/ru/city/astana/rozhdaemost", data_year="2024", published="imported 20 Sep 2026", retrieved=today),
        dict(key="fertility_rate", label="Total fertility rate", value=2.06, unit="children per woman", source="Bureau of National Statistics via qazatlas.kz",
             url="https://qazatlas.kz/ru/city/astana", data_year="2025", published="2026", retrieved=today),
    ]


ESAULET = "https://gis.esaulet.kz/server/rest/services/dop_sloi_geoportal_otkr/MapServer"


def build_references(log):
    today = timezone.now().date()

    def esaulet_count(layer):
        return requests.get(f"{ESAULET}/{layer}/query", params={"where": "1=1", "returnCountOnly": "true", "f": "json"},
                            timeout=30).json()["count"]

    def fetch():
        return json.dumps({"bus_stops": esaulet_count(8), "equipped": esaulet_count(9), "pavilions": esaulet_count(10)}).encode()

    official = json.loads(_cached("esaulet_counts.json", fetch, log))
    esaulet = dict(source="Astana GIS centre — open geoportal (gis.esaulet.kz)",
                   url="https://gis.esaulet.kz/portal/apps/experiencebuilder/experience/?id=b9f6d12fcdc644f6944a96d5c42b915f",
                   data_year="current layer", published="live service", retrieved=today)
    ato = dict(source="ATO Kazakhstan Road Safety Profile 2025 (WHO estimates)",
               url="https://asiantransportobservatory.org/analytical-outputs/roadsafetyprofiles/kazakhstan-road-safety-profile-2025/",
               data_year="2021", published="2025 (WHO estimate 2023)", retrieved=today)
    refs = [
        dict(key="official_bus_stops", label="Bus stops (official city GIS)", value=official["bus_stops"], unit="stops", **esaulet),
        dict(key="official_equipped_stops", label="Equipped bus stops (official city GIS)", value=official["equipped"], unit="stops", **esaulet),
        dict(key="official_pavilion_stops", label="Bus stops with a pavilion (official city GIS)", value=official["pavilions"], unit="stops", **esaulet),
        dict(key="road_deaths_rate", label="Road deaths per 100,000 people — Kazakhstan", value=12.2, unit="per 100,000", **ato),
        dict(key="road_deaths_total", label="Road deaths — Kazakhstan", value=2000, unit="people / year (≈)", **ato),
        dict(key="road_deaths_per_vehicles", label="Road deaths per 100,000 registered vehicles", value=53, unit="per 100,000 vehicles", **ato),
        dict(key="road_deaths_pedestrian_share", label="Share of road deaths who were pedestrians", value=27, unit="%", **ato),
        dict(key="road_crash_cost_gdp", label="Cost of road deaths & serious injuries", value=4, unit="% of GDP", **ato),
        dict(key="road_deaths_asia_pacific", label="Road deaths per 100,000 — Asia-Pacific average", value=15.2, unit="per 100,000", **ato),
    ]
    log(f"  official bus stops {official['bus_stops']:,}; ATO road-death rate 12.2 per 100,000 (2021)")
    return refs + education_references(today)


@transaction.atomic
def save(districts, stops, stations, routes, cells, green_cells=(), green_areas=(), trees=(), route_colors=None,
         safety=(), references=(), education=(), births=None):
    for model in (BirthYear, EducationPlace, ReferenceFigure, SafetyPlace, Tree, GreenArea, GreenCell, PopulationCell, BusStop,
                  RailStation, BusRoute, District):
        model.objects.all().delete()
    by_name = {}
    for d in districts:
        by_name[d["name"]] = District.objects.create(
            osm_id=d["osm_id"], name=d["name"], name_kk=d["name_kk"], population=d["population"],
            population_share=d["share"], population_change=d["yoy"], t1_congestion=d["t1"], t2_accessibility=d["t2"],
            e1_green=d.get("e1"), e2_air=d.get("e2"), s1_schools=d.get("s1"), s2_clinics=d.get("s2"),
            b1_street_safety=d.get("b1"), b2_road_safety=d.get("b2"), c1_utilities=d.get("c1"),
            c2_requests=d.get("c2"), profile=d.get("profile", ""),
            births_2024=d.get("births_2024", DISTRICT_BIRTHS_2024.get(d["name"])),
            color=d["color"], area_km2=d["area_km2"], bbox=d["bbox"],
            outline=d.get("outline") or [_simplify(r) for r in d["outer"]],
            holes=d.get("holes") if "outline" in d else [_simplify(r) for r in d["inner"]],
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
        BusRoute.objects.create(**{k: v for k, v in r.items() if k != "stop_ids"},
                                color=(route_colors or ROUTE_COLORS).get(r["short_name"], "#555"))
    PopulationCell.objects.bulk_create([
        PopulationCell(lat=c["lat"], lon=c["lon"], population=round(c["population"], 2), district=by_name[c["district"]])
        for c in cells
    ], batch_size=2000)
    GreenCell.objects.bulk_create([
        GreenCell(lat=c["lat"], lon=c["lon"], park_m2=c["park"], forest_m2=c["forest"], district=by_name[c["district"]])
        for c in green_cells
    ], batch_size=2000)
    GreenArea.objects.bulk_create([
        GreenArea(kind=g["kind"], category=g["category"], name=g["name"][:120], area_m2=g["area_m2"],
                  district=by_name[g["district"]], rings=g["rings"])
        for g in green_areas
    ], batch_size=1000)
    Tree.objects.bulk_create([
        Tree(lat=t["lat"], lon=t["lon"], species=t["species"], district=by_name[t["district"]]) for t in trees
    ], batch_size=2000)
    SafetyPlace.objects.bulk_create([
        SafetyPlace(kind=x["kind"], name=x["name"][:200], address=x.get("address", "")[:200], lat=x["lat"], lon=x["lon"],
                    source=x["source"], district=by_name[x["district"]]) for x in safety
    ], batch_size=2000)
    ReferenceFigure.objects.bulk_create([ReferenceFigure(**r) for r in references])
    EducationPlace.objects.bulk_create([
        EducationPlace(kind=x["kind"], subtype=x["subtype"], public=x["public"], name=x["name"][:200],
                       address=x.get("address", "")[:200], lat=x["lat"], lon=x["lon"], district=by_name[x["district"]])
        for x in education
    ], batch_size=2000)
    births = births or {str(y): b for y, b in BIRTHS.items()}
    BirthYear.objects.bulk_create([BirthYear(year=int(y), births=b, estimated=int(y) in BIRTHS_ESTIMATED) for y, b in births.items()])


# ---------------------------------------------------------------------------
# Committed fixture: build once (network), load anywhere (offline)
# ---------------------------------------------------------------------------
def export_fixture(log=print):
    districts = list(District.objects.all())
    name = {d.id: d.name for d in districts}
    data = {
        "version": timezone.now().isoformat(),
        "districts": [
            {"osm_id": d.osm_id, "name": d.name, "name_kk": d.name_kk, "population": d.population,
             "share": d.population_share, "yoy": d.population_change, "t1": d.t1_congestion,
             "t2": d.t2_accessibility, "e1": d.e1_green, "e2": d.e2_air, "s1": d.s1_schools, "s2": d.s2_clinics,
             "b1": d.b1_street_safety, "b2": d.b2_road_safety, "c1": d.c1_utilities, "c2": d.c2_requests,
             "profile": d.profile, "births_2024": d.births_2024, "color": d.color, "area_km2": d.area_km2,
             "bbox": d.bbox, "outline": d.outline, "holes": d.holes}
            for d in districts
        ],
        "stops": [{"name": s.name, "lat": s.lat, "lon": s.lon, "source": s.source, "district": name[s.district_id],
                   "routes": s.routes} for s in BusStop.objects.all()],
        "stations": [{"name": s.name, "name_en": s.name_en, "kind": s.kind, "lat": s.lat, "lon": s.lon,
                      "district": name.get(s.district_id)} for s in RailStation.objects.all()],
        "routes": [{f.name: getattr(r, f.name) for f in BusRoute._meta.fields if f.name not in ("id", "color")}
                   | {"stop_ids": [], "color": r.color} for r in BusRoute.objects.all()],
        "cells": [{"lat": c.lat, "lon": c.lon, "population": c.population, "district": name[c.district_id]}
                  for c in PopulationCell.objects.all()],
        "green_cells": [{"lat": c.lat, "lon": c.lon, "park": c.park_m2, "forest": c.forest_m2,
                         "district": name[c.district_id]} for c in GreenCell.objects.all()],
        "green_areas": [{"kind": g.kind, "category": g.category, "name": g.name, "area_m2": g.area_m2,
                         "district": name[g.district_id], "rings": g.rings} for g in GreenArea.objects.all()],
        "trees": [{"lat": t.lat, "lon": t.lon, "species": t.species, "district": name[t.district_id]}
                  for t in Tree.objects.all()],
        "safety": [{"kind": x.kind, "name": x.name, "address": x.address, "lat": x.lat, "lon": x.lon, "source": x.source,
                    "district": name[x.district_id]} for x in SafetyPlace.objects.all()],
        "education": [{"kind": x.kind, "subtype": x.subtype, "public": x.public, "name": x.name, "address": x.address,
                       "lat": x.lat, "lon": x.lon, "district": name[x.district_id]} for x in EducationPlace.objects.all()],
        "births": {str(b.year): b.births for b in BirthYear.objects.all()},
        "references": [{f.name: (getattr(r, f.name).isoformat() if f.name == "retrieved" and r.retrieved else getattr(r, f.name))
                        for f in ReferenceFigure._meta.fields if f.name != "id"} for r in ReferenceFigure.objects.all()],
    }
    FIXTURE.parent.mkdir(parents=True, exist_ok=True)
    with gzip.open(FIXTURE, "wt", encoding="utf-8") as f:
        json.dump(data, f, separators=(",", ":"), ensure_ascii=False)
    log(f"  wrote {FIXTURE.relative_to(settings.REPO_ROOT)} ({FIXTURE.stat().st_size / 1e6:.1f} MB)")


def fixture_needed():
    """True when any reference table is empty (e.g. a database created before a new dataset existed)."""
    if not District.objects.exists() or District.objects.filter(b1_street_safety__isnull=False).count() == 0:
        return True  # also reload when districts predate the full set of dataset indicators
    return any(not m.objects.exists() for m in (BusStop, RailStation, BusRoute, PopulationCell, GreenCell, Tree, SafetyPlace,
                                                 ReferenceFigure, EducationPlace, BirthYear))


def load_fixture(force=False, log=print):
    if not force and not fixture_needed():
        log("  open data already loaded")
        return False
    with gzip.open(FIXTURE, "rt", encoding="utf-8") as f:
        data = json.load(f)
    routes = [{k: v for k, v in r.items() if k != "color"} | {"stop_ids": set()} for r in data["routes"]]
    colors = {r["short_name"]: r["color"] for r in data["routes"]}
    save(
        data["districts"],
        [s | {"routes": set(s["routes"])} for s in data["stops"]],
        data["stations"],
        routes,
        data["cells"],
        data["green_cells"],
        data["green_areas"],
        data["trees"],
        route_colors=colors,
        safety=data.get("safety", []),
        references=[r | {"retrieved": r["retrieved"][:10] if r.get("retrieved") else None} for r in data.get("references", [])],
        education=data.get("education", []),
        births=data.get("births"),
    )
    log(f"  loaded open data built {data['version'][:10]}: {len(data['stops'])} stops, "
        f"{len(data['green_areas'])} green areas, {len(data['trees'])} trees")
    return True


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
    log("Green space (OpenStreetMap parks, lawns, forest)")
    green_cells, green_areas = build_green(districts, log)
    log("Trees (OpenStreetMap)")
    trees = build_trees(districts, log)
    log("Safety: stations (2GIS), lamps & cameras (OpenStreetMap)")
    safety = build_safety(districts, log)
    log("Schools & kindergartens (2GIS)")
    education = build_education(districts, log)
    log("Reference figures (city GIS, ATO, education)")
    references = build_references(log)
    save(districts, stops, stations, routes, cells, green_cells, green_areas, trees, safety=safety, references=references,
         education=education)
    log("Saved to PostgreSQL.")
    export_fixture(log)
