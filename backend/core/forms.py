from decimal import Decimal, InvalidOperation

from django import forms

from .budget import AREAS


def _decimal(value, field):
    try:
        number = Decimal(str(value))
    except (InvalidOperation, TypeError, ValueError):
        raise forms.ValidationError(f"{field} must be a number.")
    if not number.is_finite() or number < 0:
        raise forms.ValidationError(f"{field} can't be negative.")
    return number


def clean_section(data, label):
    """Validate one {"total", "split", "allocations"} block."""
    if not isinstance(data, dict):
        raise forms.ValidationError(f"{label} budget is missing.")
    total = _decimal(data.get("total"), f"{label} total")
    split = data.get("split")
    if split not in ("equal", "custom"):
        raise forms.ValidationError(f"{label} split must be 'equal' or 'custom'.")
    raw = data.get("allocations") or {}
    if set(raw) != set(AREAS):
        raise forms.ValidationError(f"{label} allocations must cover exactly: {', '.join(AREAS)}.")
    allocations = {area: _decimal(raw[area], f"{label} {area}") for area in AREAS}
    if sum(allocations.values()) > total:
        raise forms.ValidationError(f"{label} areas add up to more than the total budget.")
    return {"total": str(total), "split": split, "allocations": {k: str(v) for k, v in allocations.items()}}


class BudgetPlanForm(forms.Form):
    mode = forms.ChoiceField(choices=[("money", "Money"), ("units", "Units")])
    currency = forms.RegexField(regex=r"^[A-Z]{3}$", error_messages={"invalid": "Currency must be a 3-letter code."})
    money = forms.JSONField()
    units = forms.JSONField()

    def clean_money(self):
        return clean_section(self.cleaned_data["money"], "Money")

    def clean_units(self):
        return clean_section(self.cleaned_data["units"], "Units")
