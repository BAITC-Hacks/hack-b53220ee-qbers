from django.contrib import admin

from .models import (BudgetPlan, BusRoute, BusStop, District, ExchangeRates, GreenArea, GreeneryScenario, RailStation,
                     ReferenceFigure, SafetyPlace, SafetyScenario, Tree, TransportScenario, EducationPlace, EducationScenario, BirthYear)

admin.site.register(BudgetPlan)
admin.site.register(ExchangeRates)
admin.site.register(TransportScenario)
admin.site.register(GreeneryScenario)
admin.site.register(SafetyScenario)
admin.site.register(EducationScenario)
admin.site.register(BirthYear)


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


@admin.register(GreenArea)
class GreenAreaAdmin(admin.ModelAdmin):
    list_display = ("name", "kind", "category", "area_m2", "district")
    list_filter = ("category", "kind", "district")
    search_fields = ("name",)
    exclude = ("rings",)


@admin.register(Tree)
class TreeAdmin(admin.ModelAdmin):
    list_display = ("species", "district", "lat", "lon")
    list_filter = ("district",)


@admin.register(SafetyPlace)
class SafetyPlaceAdmin(admin.ModelAdmin):
    list_display = ("name", "kind", "source", "district", "address")
    list_filter = ("kind", "source", "district")
    search_fields = ("name", "address")


@admin.register(ReferenceFigure)
class ReferenceFigureAdmin(admin.ModelAdmin):
    list_display = ("label", "value", "unit", "data_year", "published", "source", "retrieved")


@admin.register(EducationPlace)
class EducationPlaceAdmin(admin.ModelAdmin):
    list_display = ("name", "kind", "subtype", "public", "district")
    list_filter = ("kind", "subtype", "district")
    search_fields = ("name", "address")
