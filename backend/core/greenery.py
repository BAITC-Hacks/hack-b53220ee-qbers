"""Greenery tab: default tree costs, scenario validation and the reference-data payload."""
from django import forms

from .models import District, GreenArea, GreenCell, PopulationCell, Tree
from .transport import _number

TREE_FOOTPRINT_M2 = 4  # each new tree counts as 4 m² of green space!

# Starting estimates in tenge — editable on the page.
DEFAULT_TREE_COSTS = {
    "sapling_kzt": 25_000,           # nursery tree, 2–3 m (elm, birch, ash)
    "planting_kzt": 15_000,          # digging, soil, stake, first watering
    "maintenance_kzt_month": 8_000 / 12,  # pruning, cutting, watering — ₸8,000 per tree per year
}


def default_scenario():
    return {
        "costs": {
            **DEFAULT_TREE_COSTS,
            "sapling_measure": "money",
            "planting_measure": "money",
            "maintenance_measure": "money",
            "maintenance_period": "year",
        },
        "maintenance_quantity": 1000,  # trees that need pruning/cutting this period
        "plantings": [],               # [{"kind": "drop", lon, lat, count} | {"kind": "mass", district, count, seed}]
        "trees_per_drop": 50,
        "radius": 500,                 # metres — "near home"
        "goal_m2": 20,                 # docx E1: 100 = ≥20 m² of green space per resident
        "include_forest": True,
    }


class GreeneryScenarioForm(forms.Form):
    costs = forms.JSONField()
    maintenance_quantity = forms.IntegerField(min_value=0, max_value=10_000_000)
    plantings = forms.JSONField(required=False)  # [] is valid — Django would call it "missing"
    trees_per_drop = forms.IntegerField(min_value=1, max_value=100_000)
    radius = forms.IntegerField(min_value=100, max_value=3000)
    goal_m2 = forms.FloatField(min_value=0, max_value=1000)
    include_forest = forms.BooleanField(required=False)

    def clean_costs(self):
        c = self.cleaned_data["costs"]
        if not isinstance(c, dict):
            raise forms.ValidationError("Costs are missing.")
        for key in ("sapling_measure", "planting_measure", "maintenance_measure"):
            if c.get(key) not in ("money", "units"):
                raise forms.ValidationError("Cost measure must be 'money' or 'units'.")
        if c.get("maintenance_period") not in ("month", "year"):
            raise forms.ValidationError("Maintenance period must be 'month' or 'year'.")
        return {
            "sapling_kzt": _number(c.get("sapling_kzt"), "Tree cost"),
            "planting_kzt": _number(c.get("planting_kzt"), "Planting cost"),
            "maintenance_kzt_month": _number(c.get("maintenance_kzt_month"), "Maintenance fee"),
            **{k: c[k] for k in ("sapling_measure", "planting_measure", "maintenance_measure", "maintenance_period")},
        }

    def clean_plantings(self):
        raw = self.cleaned_data["plantings"] or []
        if not isinstance(raw, list) or len(raw) > 1000:
            raise forms.ValidationError("Plantings must be a list (max 1,000).")
        names = set(District.objects.values_list("name", flat=True))
        out = []
        for p in raw:
            count = _number(p.get("count"), "Number of trees", 1, 5_000_000, integer=True)
            if p.get("kind") == "drop":
                out.append({"kind": "drop", "count": count,
                            "lon": round(_number(p.get("lon"), "Longitude", 70.5, 72.5), 6),
                            "lat": round(_number(p.get("lat"), "Latitude", 50.5, 51.8), 6)})
            elif p.get("kind") == "mass" and p.get("district") in names:
                out.append({"kind": "mass", "count": count, "district": p["district"],
                            "seed": _number(p.get("seed", 1), "Seed", 0, 2**31, integer=True)})
            else:
                raise forms.ValidationError("Each planting must be a map drop or a mass planting in a known district.")
        return out

    def clean_include_forest(self):
        return bool(self.cleaned_data.get("include_forest"))



def reference_payload():
    districts = list(District.objects.all())
    index = {d.id: i for i, d in enumerate(districts)}
    return {
        "districts": [
            {"name": d.name, "name_kk": d.name_kk, "color": d.color, "population": d.population,
             "population_share": d.population_share, "population_change": d.population_change,
             "e1": d.e1_green, "area_km2": d.area_km2, "bbox": d.bbox, "outline": d.outline, "holes": d.holes}
            for d in districts
        ],
        "cells": [[c.lon, c.lat, c.population, index[c.district_id]] for c in PopulationCell.objects.all()],
        # [lon, lat, park m², forest m², districtIndex]
        "green_cells": [[c.lon, c.lat, c.park_m2, c.forest_m2, index[c.district_id]] for c in GreenCell.objects.all()],
        # [category, rings, name]
        "green_areas": [[g.category, g.rings, g.name] for g in GreenArea.objects.order_by("-area_m2")],
        "trees": [[t.lon, t.lat] for t in Tree.objects.all()],
        "tree_footprint_m2": TREE_FOOTPRINT_M2,
        "defaults": default_scenario(),
        "sources": [
            {"label": "Parks, gardens, lawns, forest & mapped trees", "cite": "© OpenStreetMap contributors · ODbL",
             "url": "https://www.openstreetmap.org/copyright"},
            {"label": "District population (1 July 2026)", "cite": "qazatlas.kz", "url": "https://qazatlas.kz/ru/city/astana"},
            {"label": "E1 green-space indicator (100 = ≥20 m² per resident)", "cite": "District_Dataset_EN.docx", "url": None},
            {"label": "Map styling inspired by", "cite": "trees.sg (NParks)", "url": "https://www.trees.sg"},
        ],
    }
