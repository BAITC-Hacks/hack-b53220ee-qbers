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


# ---------------------------------------------------------------------------
# Transport tab — reference data (filled by `manage.py load_open_data`)
# ---------------------------------------------------------------------------
class District(models.Model):
    """One of Astana's six districts: OSM boundary + qazatlas population + docx indicators."""

    osm_id = models.BigIntegerField(unique=True)
    name = models.CharField(max_length=60)
    name_kk = models.CharField(max_length=60)
    population = models.PositiveIntegerField()           # qazatlas.kz, 1 July 2026
    population_share = models.FloatField()               # % of the city
    population_change = models.FloatField(null=True)     # % change over the year
    t1_congestion = models.PositiveSmallIntegerField(null=True)   # docx T1 (0–100)
    t2_accessibility = models.PositiveSmallIntegerField(null=True)  # docx T2 (0–100)
    e1_green = models.PositiveSmallIntegerField(null=True)          # docx E1 (0–100; 100 = ≥20 m²/resident)
    color = models.CharField(max_length=7)
    area_km2 = models.FloatField()
    bbox = models.JSONField()      # [minLon, minLat, maxLon, maxLat]
    outline = models.JSONField()   # outer rings: [[[lon, lat], …], …]
    holes = models.JSONField(default=list)

    class Meta:
        ordering = ["-population"]

    def __str__(self):
        return self.name


class BusStop(models.Model):
    SOURCES = [("osm", "OpenStreetMap"), ("zenodo", "Zenodo GTFS")]
    name = models.CharField(max_length=120)
    lat = models.FloatField()
    lon = models.FloatField()
    source = models.CharField(max_length=10, choices=SOURCES)
    district = models.ForeignKey(District, on_delete=models.CASCADE, related_name="bus_stops")
    routes = models.JSONField(default=list)  # Zenodo route numbers serving this stop

    def __str__(self):
        return self.name


class RailStation(models.Model):
    KINDS = [("rail", "Railway"), ("lrt", "LRT")]
    name = models.CharField(max_length=120)
    name_en = models.CharField(max_length=120)
    kind = models.CharField(max_length=4, choices=KINDS)
    lat = models.FloatField()
    lon = models.FloatField()
    district = models.ForeignKey(District, on_delete=models.SET_NULL, null=True, related_name="rail_stations")

    def __str__(self):
        return self.name_en


class BusRoute(models.Model):
    """A Zenodo GTFS route with timings summarised from Jul–Sep 2024 GPS data."""

    short_name = models.CharField(max_length=10)
    long_name = models.CharField(max_length=200)
    color = models.CharField(max_length=7)
    fleet = models.PositiveSmallIntegerField()           # median buses in service per day
    vehicles_seen = models.PositiveSmallIntegerField()   # distinct vehicles over the period
    trips_per_day = models.PositiveIntegerField()
    peak_headway = models.FloatField()                   # median minutes between buses, 07:00–09:00
    avg_headway = models.FloatField()
    trip_minutes = models.PositiveSmallIntegerField()
    first_departure = models.CharField(max_length=5)
    last_departure = models.CharField(max_length=5)
    days_observed = models.PositiveSmallIntegerField()
    shape = models.JSONField()  # {direction_id: [[lon, lat], …]} in stop order

    class Meta:
        ordering = ["short_name"]

    def __str__(self):
        return f"Route {self.short_name}"


class PopulationCell(models.Model):
    """≈200 m grid cell: district population spread by residential floor area (OSM buildings)."""

    lat = models.FloatField()
    lon = models.FloatField()
    population = models.FloatField()
    district = models.ForeignKey(District, on_delete=models.CASCADE, related_name="cells")


class TransportScenario(models.Model):
    """The user's transport-tab edits: costs, new buses per route, placed stops, walking distances."""

    data = models.JSONField()
    updated_at = models.DateTimeField(auto_now=True)


# ---------------------------------------------------------------------------
# Greenery tab — reference data (filled by `manage.py load_open_data`)
# ---------------------------------------------------------------------------
class GreenCell(models.Model):
    """≈200 m grid cell (same grid as PopulationCell) with the green area inside it."""

    lat = models.FloatField()
    lon = models.FloatField()
    park_m2 = models.FloatField(default=0)    # parks, gardens, grass, meadows
    forest_m2 = models.FloatField(default=0)  # forest, woodland, scrub (incl. the green belt)
    district = models.ForeignKey(District, on_delete=models.CASCADE, related_name="green_cells")


class GreenArea(models.Model):
    """A park / wood / lawn outline for drawing on the map (simplified)."""

    kind = models.CharField(max_length=30)
    category = models.CharField(max_length=10)  # "park" or "forest"
    name = models.CharField(max_length=120, blank=True)
    area_m2 = models.FloatField()
    district = models.ForeignKey(District, on_delete=models.CASCADE, related_name="green_areas")
    rings = models.JSONField()


class Tree(models.Model):
    """An individually mapped tree (OpenStreetMap natural=tree)."""

    lat = models.FloatField()
    lon = models.FloatField()
    species = models.CharField(max_length=80, blank=True)
    district = models.ForeignKey(District, on_delete=models.CASCADE, related_name="trees")


class GreeneryScenario(models.Model):
    """The user's greenery-tab edits: tree costs, plantings, walking radius, goal."""

    data = models.JSONField()
    updated_at = models.DateTimeField(auto_now=True)
