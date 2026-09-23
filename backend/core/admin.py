from django.contrib import admin

from .models import BudgetPlan, BusRoute, BusStop, District, ExchangeRates, RailStation, TransportScenario

admin.site.register(BudgetPlan)
admin.site.register(ExchangeRates)
admin.site.register(TransportScenario)


@admin.register(District)
class DistrictAdmin(admin.ModelAdmin):
    list_display = ("name", "population", "population_share", "area_km2", "t1_congestion", "t2_accessibility")
    exclude = ("outline", "holes")


@admin.register(BusStop)
class BusStopAdmin(admin.ModelAdmin):
    list_display = ("name", "district", "source", "routes")
    list_filter = ("district", "source")
    search_fields = ("name",)


@admin.register(RailStation)
class RailStationAdmin(admin.ModelAdmin):
    list_display = ("name_en", "name", "kind", "district")
    list_filter = ("kind",)


@admin.register(BusRoute)
class BusRouteAdmin(admin.ModelAdmin):
    list_display = ("short_name", "long_name", "fleet", "peak_headway", "trip_minutes")
    exclude = ("shape",)
