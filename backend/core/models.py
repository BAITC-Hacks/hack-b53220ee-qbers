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
    # Remaining District_Dataset_EN.docx baselines (0–100, higher is better; Saraishyq not covered)
    e2_air = models.PositiveSmallIntegerField(null=True)
    s1_schools = models.PositiveSmallIntegerField(null=True)
    s2_clinics = models.PositiveSmallIntegerField(null=True)
    b1_street_safety = models.PositiveSmallIntegerField(null=True)  # 100 = lighting and cameras everywhere
    b2_road_safety = models.PositiveSmallIntegerField(null=True)    # 100 = minimal injury accidents
    c1_utilities = models.PositiveSmallIntegerField(null=True)
    c2_requests = models.PositiveSmallIntegerField(null=True)
    profile = models.CharField(max_length=200, blank=True)          # docx district profile
    births_2024 = models.PositiveIntegerField(null=True)            # qazatlas.kz (Bureau of National Statistics)
    # District_Dataset_EN.docx "Population share" column (5 original districts only;
    # Saraishyq post-dates the dataset). Used only for the Score tab's D_avg weighting.
    docx_population_share = models.FloatField(null=True)
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



# ---------------------------------------------------------------------------
# Safety tab — reference data
# ---------------------------------------------------------------------------
class SafetyPlace(models.Model):
    KINDS = [
        ("fire_station", "Fire station"), ("police_station", "Police department"), ("police_post", "Local police post"),
        ("lamp", "Street lamp"), ("speed_camera", "Speed camera"), ("cctv", "CCTV camera"),
    ]
    SOURCES = [("2gis", "2GIS directory"), ("osm", "OpenStreetMap")]
    kind = models.CharField(max_length=20, choices=KINDS)
    name = models.CharField(max_length=200, blank=True)
    address = models.CharField(max_length=200, blank=True)
    lat = models.FloatField()
    lon = models.FloatField()
    source = models.CharField(max_length=10, choices=SOURCES)
    district = models.ForeignKey(District, on_delete=models.CASCADE, related_name="safety_places")

    def __str__(self):
        return self.name or self.get_kind_display()


class ReferenceFigure(models.Model):
    """A published statistic shown on the dashboard, with its source and how recent it is."""

    key = models.CharField(max_length=60, unique=True)
    label = models.CharField(max_length=200)
    value = models.FloatField()
    unit = models.CharField(max_length=60, blank=True)
    data_year = models.CharField(max_length=20, blank=True)   # the year the figure describes
    published = models.CharField(max_length=40, blank=True)   # when the source published it
    source = models.CharField(max_length=200)
    url = models.URLField(max_length=400, blank=True)
    retrieved = models.DateField(null=True)

    def __str__(self):
        return self.label


class SafetyScenario(models.Model):
    """The user's safety-tab edits: new lamps/CCTV/speed cameras, vehicles per district, costs."""

    data = models.JSONField()
    updated_at = models.DateTimeField(auto_now=True)



# ---------------------------------------------------------------------------
# Social services tab — schools & kindergartens
# ---------------------------------------------------------------------------
class EducationPlace(models.Model):
    KINDS = [("school", "School"), ("kindergarten", "Kindergarten")]
    kind = models.CharField(max_length=15, choices=KINDS)
    subtype = models.CharField(max_length=40, blank=True)  # e.g. gymnasium, lyceum, state / private kindergarten
    public = models.BooleanField(default=True)
    name = models.CharField(max_length=200, blank=True)
    address = models.CharField(max_length=200, blank=True)
    lat = models.FloatField()
    lon = models.FloatField()
    district = models.ForeignKey(District, on_delete=models.CASCADE, related_name="education_places")

    def __str__(self):
        return self.name


class BirthYear(models.Model):
    """Births registered in Astana (Bureau of National Statistics via qazatlas.kz)."""

    year = models.PositiveSmallIntegerField(unique=True)
    births = models.PositiveIntegerField()
    estimated = models.BooleanField(default=False)  # e.g. a year summed from monthly figures

    class Meta:
        ordering = ["year"]


class EducationScenario(models.Model):
    """The user's social-services edits: new schools/kindergartens, staff, pay, costs, projection settings."""

    data = models.JSONField()
    updated_at = models.DateTimeField(auto_now=True)



# ---------------------------------------------------------------------------
# City services tab — utility complaints (ikomekastana.kz) + user fixes
# ---------------------------------------------------------------------------
class CityServiceStat(models.Model):
    """Residents' appeals to Astana's monitoring centre, by year and service category."""

    UTILITIES = [("electricity", "Electricity"), ("water", "Water"), ("heating", "Heating"), ("sewage", "Sewage")]
    year = models.PositiveSmallIntegerField()
    utility = models.CharField(max_length=15, choices=UTILITIES)
    category_name = models.CharField(max_length=120)  # original Russian category name
    count = models.PositiveIntegerField()

    class Meta:
        unique_together = ("year", "utility")
        ordering = ["utility", "year"]


class CityServiceScenario(models.Model):
    """The user's city-services edits: fixes placed on the map, costs."""

    data = models.JSONField()
    updated_at = models.DateTimeField(auto_now=True)


class TranslationCache(models.Model):
    """Cached Google Cloud Translation API v2 results, so repeated page loads and
    teammates don't re-bill the same strings."""

    target = models.CharField(max_length=8)
    text_hash = models.CharField(max_length=64)
    source_text = models.TextField()
    translated_text = models.TextField()

    class Meta:
        unique_together = ("target", "text_hash")
