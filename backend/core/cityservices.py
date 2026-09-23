"""City services tab: utility complaints (ikomekastana.kz), fixes, costs, payload."""
from django import forms

from .models import CityServiceStat, District, PopulationCell
from .transport import _number

UTILITIES = ["electricity", "water", "heating", "sewage"]
FIXES = ["water_pipe", "electrical_wiring", "heater"]  # what the user drags onto the map

# Starting estimates in tenge — clearly editable. "Heater" = a district heating substation upgrade.
DEFAULT_COSTS = {
    "water_pipe": {"setup": 60_000_000, "maintenance": 350_000},        # ~200 m of pipe replacement
    "electrical_wiring": {"setup": 35_000_000, "maintenance": 200_000},  # cable + transformer branch upgrade
    "heater": {"setup": 220_000_000, "maintenance": 900_000},            # local heating substation (ITP) rebuild
}


def default_scenario():
    return {
        "fixes": [],  # [{"kind": "water_pipe"|"electrical_wiring"|"heater", "lon": …, "lat": …}]
        "costs": {
            k: {"setup_kzt": c["setup"], "maintenance_kzt_month": c["maintenance"], "setup_measure": "money",
                "maintenance_measure": "money", "maintenance_period": "month"}
            for k, c in DEFAULT_COSTS.items()
        },
    }


class CityServiceScenarioForm(forms.Form):
    fixes = forms.JSONField(required=False)  # [] is valid
    costs = forms.JSONField()

    def clean_fixes(self):
        raw = self.cleaned_data["fixes"] or []
        if not isinstance(raw, list) or len(raw) > 1000:
            raise forms.ValidationError("Fixes must be a list (max 1,000).")
        out = []
        for f in raw:
            if not isinstance(f, dict) or f.get("kind") not in FIXES:
                raise forms.ValidationError(f"Each fix needs a kind: {', '.join(FIXES)}.")
            out.append({"kind": f["kind"], "lon": round(_number(f.get("lon"), "Longitude", 70.5, 72.5), 6),
                        "lat": round(_number(f.get("lat"), "Latitude", 50.5, 51.8), 6)})
        return out

    def clean_costs(self):
        raw = self.cleaned_data["costs"]
        if not isinstance(raw, dict) or set(raw) != set(FIXES):
            raise forms.ValidationError(f"Costs must cover: {', '.join(FIXES)}.")
        out = {}
        for k, c in raw.items():
            if c.get("setup_measure") not in ("money", "units") or c.get("maintenance_measure") not in ("money", "units"):
                raise forms.ValidationError("Cost measure must be 'money' or 'units'.")
            if c.get("maintenance_period") not in ("month", "year"):
                raise forms.ValidationError("Maintenance period must be 'month' or 'year'.")
            out[k] = {"setup_kzt": _number(c.get("setup_kzt"), f"{k} setup cost"),
                      "maintenance_kzt_month": _number(c.get("maintenance_kzt_month"), f"{k} maintenance"),
                      **{f: c[f] for f in ("setup_measure", "maintenance_measure", "maintenance_period")}}
        return out


def reference_payload():
    from .safety import district_payload  # shared helper

    districts = list(District.objects.all())
    index = {d.id: i for i, d in enumerate(districts)}
    stats = list(CityServiceStat.objects.all())
    by_year = {}
    for s in stats:
        by_year.setdefault(s.utility, {})[s.year] = {"count": s.count, "category_name": s.category_name}
    return {
        "districts": district_payload(districts),
        "cells": [[c.lon, c.lat, c.population, index[c.district_id]] for c in PopulationCell.objects.all()],
        "series": {u: by_year.get(u, {}) for u in UTILITIES},
        "defaults": default_scenario(),
        "fixes": FIXES,
        "utilities": UTILITIES,
        "sources": [
            {"label": "Residents' appeals about electricity, water, heating & sewage supply, by year",
             "cite": "Astana City Monitoring & Rapid-Response Centre (ikomekastana.kz/stats)",
             "url": "https://ikomekastana.kz/stats"},
            {"label": "C1 utility-reliability indicator (100 = no heating/water failures all year)",
             "cite": "District_Dataset_EN.docx", "url": None},
            {"label": "District population (1 July 2026)", "cite": "qazatlas.kz", "url": "https://qazatlas.kz/ru/city/astana"},
        ],
        "note": ("ikomekastana.kz publishes how many residents complained about each utility citywide, not where "
                 "outages happened or a per-district breakdown — there is no open dataset for that. The map heat "
                 "layer therefore spreads each district's estimated share (by population) of the citywide complaint "
                 "count; it is not a map of real fault locations."),
    }
