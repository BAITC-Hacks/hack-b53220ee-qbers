"""Budget areas and defaults shared by the model, form and API."""
from decimal import Decimal

# Order matters: it's the tab order in the UI.
AREAS = ["transport", "greenery", "social", "safety", "city"]

DEFAULT_MONEY_TOTAL = Decimal("1000000000")  # ₸1 billion
DEFAULT_UNITS_TOTAL = Decimal("10000")


def equal_split(total, decimals):
    """Split `total` into len(AREAS) parts that add up exactly (remainder goes to the first areas)."""
    step = Decimal(1).scaleb(-decimals)
    base = (Decimal(total) / len(AREAS)).quantize(step, rounding="ROUND_DOWN")
    remainder = int((Decimal(total) - base * len(AREAS)) / step)
    return {area: base + (step if i < remainder else 0) for i, area in enumerate(AREAS)}


def default_section(total, decimals):
    return {"total": total, "split": "equal", "allocations": equal_split(total, decimals)}
