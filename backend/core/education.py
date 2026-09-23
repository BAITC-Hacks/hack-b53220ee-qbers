"""Social services tab: schools & kindergartens — defaults, scenario validation, payload."""
from django import forms

from .models import BirthYear, District, EducationPlace
from .safety import district_payload, references
from .transport import _number

FACILITIES = ["school", "kindergarten"]
STAFF = ["teachers", "workers"]


def default_scenario():
    names = list(District.objects.values_list("name", flat=True))
    return {
        "placements": [],                                   # [{"kind": "school"|"kindergarten", "lon", "lat"}]
        "added": {d: {k: 0 for k in FACILITIES} for d in names},
        "capacity": {"school": 1200, "kindergarten": 320},  # places per new building (Astana's standard sizes)
        "staff": {"school": {"teachers": 20, "workers": 10}, "kindergarten": {"teachers": 12, "workers": 6}},
        "costs": {
            # Build cost per building (tenge) — Astana school for 1,200 pupils; Ministry kindergarten estimate.
            "build": {"school": 7_000_000_000, "kindergarten": 1_500_000_000, "measure": "money"},
            # Monthly pay per person (tenge) = the maintenance cost.
            "pay": {"teacher": 393_000, "kg_teacher": 258_000, "worker": 150_000, "measure": "money", "period": "month"},
        },
        "projection": {"births_change_pct": 0.0, "migration_uplift_pct": None},  # None = calibrated from the data
    }


class EducationScenarioForm(forms.Form):
    placements = forms.JSONField(required=False)  # [] is valid
    added = forms.JSONField()
    capacity = forms.JSONField()
    staff = forms.JSONField()
    costs = forms.JSONField()
    projection = forms.JSONField()

    def clean_placements(self):
        raw = self.cleaned_data["placements"] or []
        if not isinstance(raw, list) or len(raw) > 1000:
            raise forms.ValidationError("Placements must be a list (max 1,000).")
        out = []
        for p in raw:
            if not isinstance(p, dict) or p.get("kind") not in FACILITIES:
                raise forms.ValidationError("Each placement needs a kind: school or kindergarten.")
            out.append({"kind": p["kind"], "lon": round(_number(p.get("lon"), "Longitude", 70.5, 72.5), 6),
                        "lat": round(_number(p.get("lat"), "Latitude", 50.5, 51.8), 6)})
        return out

    def clean_added(self):
        raw = self.cleaned_data["added"]
        names = set(District.objects.values_list("name", flat=True))
        if not isinstance(raw, dict) or not set(raw) <= names:
            raise forms.ValidationError("Additions must be given per known district.")
        return {d: {k: _number((raw.get(d) or {}).get(k, 0), f"New {k}s in {d}", 0, 10_000, integer=True) for k in FACILITIES}
                for d in sorted(names)}

    def clean_capacity(self):
        raw = self.cleaned_data["capacity"] or {}
        return {k: _number(raw.get(k), f"{k.title()} capacity", 1, 20_000, integer=True) for k in FACILITIES}

    def clean_staff(self):
        raw = self.cleaned_data["staff"] or {}
        return {k: {s: _number((raw.get(k) or {}).get(s), f"{k} {s}", 0, 10_000, integer=True) for s in STAFF} for k in FACILITIES}

    def clean_costs(self):
        raw = self.cleaned_data["costs"] or {}
        b, p = raw.get("build") or {}, raw.get("pay") or {}
        if b.get("measure") not in ("money", "units") or p.get("measure") not in ("money", "units"):
            raise forms.ValidationError("Cost measure must be 'money' or 'units'.")
        if p.get("period") not in ("month", "year"):
            raise forms.ValidationError("Pay period must be 'month' or 'year'.")
        return {
            "build": {k: _number(b.get(k), f"{k.title()} build cost") for k in FACILITIES} | {"measure": b["measure"]},
            "pay": {k: _number(p.get(k), f"{k} pay") for k in ("teacher", "kg_teacher", "worker")}
                   | {"measure": p["measure"], "period": p["period"]},
        }

    def clean_projection(self):
        raw = self.cleaned_data["projection"] or {}
        uplift = raw.get("migration_uplift_pct")
        return {
            "births_change_pct": _number(raw.get("births_change_pct", 0), "Births change per year (%)", -20, 20),
            "migration_uplift_pct": None if uplift in (None, "") else _number(uplift, "Migration uplift (%)", 0, 100),
        }


def reference_payload():
    districts = list(District.objects.all())
    index = {d.id: i for i, d in enumerate(districts)}
    refs = references()
    return {
        "districts": district_payload(districts) and [
            {**x, "births_2024": d.births_2024} for x, d in zip(district_payload(districts), districts)
        ],
        # [kind, lon, lat, districtIndex, name, subtype, public, address]
        "places": [[p.kind, p.lon, p.lat, index[p.district_id], p.name, p.subtype, p.public, p.address]
                   for p in EducationPlace.objects.all()],
        "births": {b.year: b.births for b in BirthYear.objects.all()},
        "births_estimated": [b.year for b in BirthYear.objects.filter(estimated=True)],
        "references": refs,
        "defaults": default_scenario(),
        "sources": [
            {"label": "Schools & kindergartens on the map", "cite": "2GIS directory (catalog API)", "url": "https://2gis.kz/astana"},
            {"label": "Births by year (2000–2025) and by district (2024)", "cite": "Bureau of National Statistics via qazatlas.kz",
             "url": "https://qazatlas.kz/ru/city/astana/rozhdaemost"},
            {"label": refs["school_pupils"]["label"] + " · shortage of places", "cite": refs["school_pupils"]["source"], "url": refs["school_pupils"]["url"]},
            {"label": "Kindergarten places, enrolment & coverage", "cite": refs["kg_capacity"]["source"], "url": refs["kg_capacity"]["url"]},
            {"label": "Teacher pay (2025)", "cite": refs["pay_teacher"]["source"], "url": refs["pay_teacher"]["url"]},
            {"label": "Kindergarten teacher pay", "cite": refs["pay_kg_teacher"]["source"], "url": refs["pay_kg_teacher"]["url"]},
            {"label": "Education-sector average wage · minimum wage", "cite": f"{refs['pay_education_avg']['source']} · {refs['min_wage']['source']}",
             "url": refs["pay_education_avg"]["url"]},
            {"label": "Build costs", "cite": f"{refs['cost_school']['source']} · {refs['cost_kindergarten']['source']}", "url": refs["cost_school"]["url"]},
            {"label": "S1 schools & kindergartens indicator (100 = capacity met, no second shifts)", "cite": "District_Dataset_EN.docx", "url": None},
            {"label": "District population (1 July 2026)", "cite": "qazatlas.kz", "url": "https://qazatlas.kz/ru/city/astana"},
        ],
    }
