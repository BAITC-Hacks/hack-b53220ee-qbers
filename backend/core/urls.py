from django.urls import path

from . import views

urlpatterns = [
    path("health/", views.health),
    path("csrf/", views.csrf),
    path("plan/", views.plan),
    path("currency/", views.currency),
    path("transport/", views.transport_data),
    path("transport/scenario/", views.transport_scenario),
    path("greenery/", views.greenery_data),
    path("greenery/scenario/", views.greenery_scenario),
    path("auth/google/", views.google_login),
    path("auth/me/", views.me),
    path("auth/logout/", views.logout_view),
]
