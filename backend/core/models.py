from django.db import models


class BudgetPlan(models.Model):
    """The city budget: an overall total split across the five areas.

    Money and units are kept side by side so switching modes never loses either.
    Each section is {"total": "…", "split": "equal"|"custom", "allocations": {area: "…"}}.
    """

    MODES = [("money", "Money"), ("units", "Units")]

    name = models.CharField(max_length=120, default="Astana city budget")
    mode = models.CharField(max_length=10, choices=MODES, default="money")
    currency = models.CharField(max_length=3, default="KZT")
    money = models.JSONField()
    units = models.JSONField()
    updated_at = models.DateTimeField(auto_now=True)

    def __str__(self):
        return f"{self.name} ({self.mode})"


class ExchangeRates(models.Model):
    """Cached currencyapi.com response. The free plan allows 300 calls a month, so we reuse it."""

    base = models.CharField(max_length=3, default="KZT")
    rates = models.JSONField()  # {"USD": 0.00223, …} — units of that currency per 1 KZT
    source_updated_at = models.DateTimeField(null=True)
    fetched_at = models.DateTimeField(auto_now_add=True)

    class Meta:
        get_latest_by = "fetched_at"

    def __str__(self):
        return f"{self.base} rates @ {self.fetched_at:%Y-%m-%d %H:%M}"
