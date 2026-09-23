"""Transport tab: default costs, scenario validation and the reference-data payload."""
from django import forms

from .models import BusRoute, BusStop, District, PopulationCell, RailStation

ASSETS = ["bus_stop", "rail_station", "bus", "train"]

# Starting estimates in tenge — clearly labelled as editable on the page.
DEFAULT_COSTS = {
    "bus_stop": {"setup": 4_500_000, "maintenance": 45_000},          # heated shelter pavilion
    "rail_station": {"setup": 2_000_000_000, "maintenance": 12_000_000},  # small commuter halt
    "bus": {"setup": 85_000_000, "maintenance": 1_200_000},           # 12 m city bus
    "train": {"setup": 5_000_000_000, "maintenance": 35_000_000},     # commuter EMU / LRT set
}


def default_scenario():
    return {
        # Costs are stored in tenge; maintenance per month. The *_measure/period keys
        # only remember how the user prefers to see them (currency or units, /month or /year).
        "costs": {
            asset: {
                "setup_kzt": c["setup"],
                "maintenance_kzt_month": c["maintenance"],
                "setup_measure": "money",
                "maintenance_measure": "money",
                "maintenance_period": "month",
            }
            for asset, c in DEFAULT_COSTS.items()
        },
        "new_buses": {r.short_name: 0 for r in BusRoute.objects.all()},
        "new_trains": 0,
        "new_stops": [],  # [{"kind": "bus"|"rail", "lon": …, "lat": …}]
        "distances": {"bus": 500, "rail": 1000},  # metres — docx T2 uses 500 m for stops
        "goals": {"bus_coverage": 90, "rail_coverage": 50, "stops_per_10k": 7},
        "existing_override": {"bus_stops": None, "rail_stations": None},
    }


def _number(value, label, minimum=0, maximum=None, integer=False):
    try:
        n = int(value) if integer else float(value)
    except (TypeError, ValueError):
        raise forms.ValidationError(f"{label} must be a number.")
    if n != n or n < minimum or (maximum is not None and n > maximum):
        raise forms.ValidationError(f"{label} must be between {minimum} and {maximum}." if maximum else f"{label} can't be below {minimum}.")
    return n


class TransportScenarioForm(forms.Form):
    costs = forms.JSONField()
    new_buses = forms.JSONField()
    new_trains = forms.IntegerField(min_value=0, max_value=500)
    # required=False: Django treats [] as empty, and "no new stops" is a valid scenario.
    new_stops = forms.JSONField(required=False)
    distances = forms.JSONField()
    goals = forms.JSONField()
    existing_override = forms.JSONField()

    def clean_costs(self):
        raw = self.cleaned_data["costs"]
        if not isinstance(raw, dict) or set(raw) != set(ASSETS):
            raise forms.ValidationError(f"Costs must cover: {', '.join(ASSETS)}.")
        out = {}
        for asset in ASSETS:
            c = raw[asset]
            if c.get("setup_measure") not in ("money", "units") or c.get("maintenance_measure") not in ("money", "units"):
                raise forms.ValidationError("Cost measure must be 'money' or 'units'.")
            if c.get("maintenance_period") not in ("month", "year"):
                raise forms.ValidationError("Maintenance period must be 'month' or 'year'.")
            out[asset] = {
                "setup_kzt": _number(c.get("setup_kzt"), f"{asset} setup cost"),
                "maintenance_kzt_month": _number(c.get("maintenance_kzt_month"), f"{asset} maintenance cost"),
                "setup_measure": c["setup_measure"],
                "maintenance_measure": c["maintenance_measure"],
                "maintenance_period": c["maintenance_period"],
            }
        return out

    def clean_new_buses(self):
        raw = self.cleaned_data["new_buses"]
        routes = set(BusRoute.objects.values_list("short_name", flat=True))
        if not isinstance(raw, dict) or not set(raw) <= routes:
            raise forms.ValidationError("New buses must be given per known route.")
        return {r: _number(raw.get(r, 0), f"New buses on route {r}", 0, 500, integer=True) for r in sorted(routes)}

    def clean_new_stops(self):
        raw = self.cleaned_data["new_stops"] or []
        if not isinstance(raw, list) or len(raw) > 500:
            raise forms.ValidationError("New stops must be a list (max 500).")
        stops = []
        for s in raw:
            if not isinstance(s, dict) or s.get("kind") not in ("bus", "rail"):
                raise forms.ValidationError("Each new stop needs a kind of 'bus' or 'rail'.")
            lon = _number(s.get("lon"), "Stop longitude", 70.5, 72.5)
            lat = _number(s.get("lat"), "Stop latitude", 50.5, 51.8)
            stops.append({"kind": s["kind"], "lon": round(lon, 6), "lat": round(lat, 6)})
        return stops

    def clean_distances(self):
        raw = self.cleaned_data["distances"] or {}
        return {k: _number(raw.get(k), f"{k.title()} distance (m)", 50, 5000, integer=True) for k in ("bus", "rail")}

    def clean_goals(self):
        raw = self.cleaned_data["goals"] or {}
        return {
            "bus_coverage": _number(raw.get("bus_coverage"), "Bus coverage goal (%)", 0, 100),
            "rail_coverage": _number(raw.get("rail_coverage"), "Rail coverage goal (%)", 0, 100),
            "stops_per_10k": _number(raw.get("stops_per_10k"), "Stop density goal", 0, 1000),
        }

    def clean_existing_override(self):
        raw = self.cleaned_data["existing_override"] or {}
        return {k: None if raw.get(k) in (None, "") else _number(raw.get(k), f"Existing {k.replace('_', ' ')}", 0, 100_000, integer=True)
                for k in ("bus_stops", "rail_stations")}


def reference_payload():
    """Everything the transport tab draws and calculates with, in compact form."""
    districts = list(District.objects.all())
    index = {d.id: i for i, d in enumerate(districts)}
    return {
        "districts": [
            {
                "name": d.name, "name_kk": d.name_kk, "color": d.color, "population": d.population,
                "population_share": d.population_share, "population_change": d.population_change,
                "t1": d.t1_congestion, "t2": d.t2_accessibility, "area_km2": d.area_km2, "bbox": d.bbox,
                "outline": d.outline, "holes": d.holes,
            }
            for d in districts
        ],
        # Compact rows keep the payload small: [lon, lat, districtIndex, name, routes]
        "bus_stops": [[s.lon, s.lat, index[s.district_id], s.name, s.routes] for s in BusStop.objects.all()],
        "rail_stations": [
            {"name": s.name_en, "name_local": s.name, "kind": s.kind, "lon": s.lon, "lat": s.lat,
             "district": index.get(s.district_id)}
            for s in RailStation.objects.all()
        ],
        "routes": [
            {k: getattr(r, k) for k in ("short_name", "long_name", "color", "fleet", "vehicles_seen", "trips_per_day",
                                        "peak_headway", "avg_headway", "trip_minutes", "first_departure", "last_departure",
                                        "days_observed", "shape")}
            for r in BusRoute.objects.all()
        ],
        # [lon, lat, population, districtIndex]
        "cells": [[c.lon, c.lat, c.population, index[c.district_id]] for c in PopulationCell.objects.all()],
        "defaults": default_scenario(),
        "sources": [
            {"label": "Bus routes 10, 12, 46 — stops & timings (GPS, Jul–Sep 2024)",
             "cite": "Mansurova et al. (2025), From Raw GPS to GTFS, Zenodo · CC BY 4.0",
             "url": "https://doi.org/10.5281/zenodo.15769359"},
            {"label": "Bus stops, rail & LRT stations, district boundaries, buildings",
             "cite": "© OpenStreetMap contributors · ODbL", "url": "https://www.openstreetmap.org/copyright"},
            {"label": "District population (1 July 2026)", "cite": "qazatlas.kz", "url": "https://qazatlas.kz/ru/city/astana"},
            {"label": "District indicators T1 (congestion) & T2 (transit access: 500 m, ≤10 min)",
             "cite": "District_Dataset_EN.docx", "url": None},
        ],
    }
