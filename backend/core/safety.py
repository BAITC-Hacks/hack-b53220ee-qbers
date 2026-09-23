"""Safety tab: default costs, scenario validation and the reference-data payload."""
from django import forms

from .models import District, ReferenceFigure, SafetyPlace
from .transport import _number

# Things the user can place on the map or add per district.
INFRA = ["lamp", "cctv", "speed_camera"]
# Vehicles have no open data at all — the user adds them per district.
VEHICLES = ["fire_truck", "ambulance", "police_car", "riot_vehicle", "snow_plough"]

# Starting estimates in tenge (setup = purchase/installation; maintenance per month,
# which should include fuel or charging for vehicles). Editable on the page.
DEFAULT_COSTS = {
    "lamp": (650_000, 4_000),              # LED lamp, pole and cabling; electricity + upkeep
    "cctv": (1_500_000, 20_000),           # camera, mount, network link; data + upkeep
    "speed_camera": (18_000_000, 250_000),  # fixed speed-enforcement unit; calibration + data
    "fire_truck": (180_000_000, 900_000),
    "ambulance": (45_000_000, 400_000),
    "police_car": (20_000_000, 200_000),
    "riot_vehicle": (150_000_000, 700_000),
    "snow_plough": (95_000_000, 600_000),
}


def default_scenario():
    names = list(District.objects.values_list("name", flat=True))
    return {
        "costs": {
            k: {"setup_kzt": s, "maintenance_kzt_month": m, "setup_measure": "money", "maintenance_measure": "money",
                "maintenance_period": "month"}
            for k, (s, m) in DEFAULT_COSTS.items()
        },
        "placements": [],   # [{"kind": "lamp"|"cctv"|"speed_camera", "lon": …, "lat": …}]
        "added": {d: {k: 0 for k in INFRA} for d in names},        # bulk additions per district
        "vehicles": {d: {k: 0 for k in VEHICLES} for d in names},  # new vehicles per district
    }


class SafetyScenarioForm(forms.Form):
    costs = forms.JSONField()
    placements = forms.JSONField(required=False)  # [] is valid
    added = forms.JSONField()
    vehicles = forms.JSONField()

    def clean_costs(self):
        raw = self.cleaned_data["costs"]
        if not isinstance(raw, dict) or set(raw) != set(DEFAULT_COSTS):
            raise forms.ValidationError(f"Costs must cover: {', '.join(DEFAULT_COSTS)}.")
        out = {}
        for k, c in raw.items():
            if c.get("setup_measure") not in ("money", "units") or c.get("maintenance_measure") not in ("money", "units"):
                raise forms.ValidationError("Cost measure must be 'money' or 'units'.")
            if c.get("maintenance_period") not in ("month", "year"):
                raise forms.ValidationError("Maintenance period must be 'month' or 'year'.")
            out[k] = {"setup_kzt": _number(c.get("setup_kzt"), f"{k} cost"),
                      "maintenance_kzt_month": _number(c.get("maintenance_kzt_month"), f"{k} maintenance"),
                      **{f: c[f] for f in ("setup_measure", "maintenance_measure", "maintenance_period")}}
        return out

    def clean_placements(self):
        raw = self.cleaned_data["placements"] or []
        if not isinstance(raw, list) or len(raw) > 2000:
            raise forms.ValidationError("Placements must be a list (max 2,000).")
        out = []
        for p in raw:
            if not isinstance(p, dict) or p.get("kind") not in INFRA:
                raise forms.ValidationError("Each placement needs a kind: lamp, cctv or speed_camera.")
            out.append({"kind": p["kind"], "lon": round(_number(p.get("lon"), "Longitude", 70.5, 72.5), 6),
                        "lat": round(_number(p.get("lat"), "Latitude", 50.5, 51.8), 6)})
        return out

    def _per_district(self, raw, keys, label):
        names = set(District.objects.values_list("name", flat=True))
        if not isinstance(raw, dict) or not set(raw) <= names:
            raise forms.ValidationError(f"{label} must be given per known district.")
        return {d: {k: _number((raw.get(d) or {}).get(k, 0), f"{label} ({d}, {k})", 0, 1_000_000, integer=True) for k in keys}
                for d in sorted(names)}

    def clean_added(self):
        return self._per_district(self.cleaned_data["added"], INFRA, "Additions")

    def clean_vehicles(self):
        return self._per_district(self.cleaned_data["vehicles"], VEHICLES, "Vehicles")


def district_payload(districts):
    return [
        {"name": d.name, "name_kk": d.name_kk, "color": d.color, "population": d.population,
         "population_share": d.population_share, "population_change": d.population_change, "area_km2": d.area_km2,
         "bbox": d.bbox, "outline": d.outline, "holes": d.holes, "profile": d.profile,
         "indicators": {"t1": d.t1_congestion, "t2": d.t2_accessibility, "e1": d.e1_green, "e2": d.e2_air,
                        "s1": d.s1_schools, "s2": d.s2_clinics, "b1": d.b1_street_safety, "b2": d.b2_road_safety,
                        "c1": d.c1_utilities, "c2": d.c2_requests}}
        for d in districts
    ]


def references():
    return {r.key: {"label": r.label, "value": r.value, "unit": r.unit, "data_year": r.data_year, "published": r.published,
                    "source": r.source, "url": r.url, "retrieved": r.retrieved.isoformat() if r.retrieved else None}
            for r in ReferenceFigure.objects.all()}


def reference_payload():
    districts = list(District.objects.all())
    index = {d.id: i for i, d in enumerate(districts)}
    places = list(SafetyPlace.objects.all())
    return {
        "districts": district_payload(districts),
        # [kind, lon, lat, districtIndex, name, address, source]
        "places": [[p.kind, p.lon, p.lat, index[p.district_id], p.name, p.address, p.source] for p in places],
        "references": references(),
        "defaults": default_scenario(),
        "infra": INFRA,
        "vehicles": VEHICLES,
        "sources": [
            {"label": "Fire stations, police departments & local police posts", "cite": "2GIS directory (catalog API)",
             "url": "https://2gis.kz/astana"},
            {"label": "Street lamps, speed cameras & CCTV (as mapped)", "cite": "© OpenStreetMap contributors · ODbL — the data behind MapComplete's street-lighting map",
             "url": "https://mapcomplete.org/street_lighting.html?z=15.4&lat=51.1117994&lon=71.4147611"},
            {"label": "City layers checked for lighting / cameras / accidents (none published openly)",
             "cite": "Astana GIS centre open geoportal (gis.esaulet.kz)",
             "url": "https://gis.esaulet.kz/portal/apps/experiencebuilder/experience/?id=b9f6d12fcdc644f6944a96d5c42b915f&page=page_15"},
            {"label": "Road deaths (national, 2021 WHO estimate)", "cite": "ATO Kazakhstan Road Safety Profile 2025",
             "url": "https://asiantransportobservatory.org/analytical-outputs/roadsafetyprofiles/kazakhstan-road-safety-profile-2025/"},
            {"label": "B1 street safety & B2 road safety targets; measures M10/M11", "cite": "District_Dataset_EN.docx", "url": None},
            {"label": "District population (1 July 2026)", "cite": "qazatlas.kz", "url": "https://qazatlas.kz/ru/city/astana"},
        ],
    }
