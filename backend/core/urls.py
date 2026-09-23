from django.urls import path

from . import views

urlpatterns = [
    path("health/", views.health),
    path("csrf/", views.csrf),
    path("stats/", views.stats),
    path("locations/", views.locations),
    path("waitlist/", views.waitlist),
    path("auth/google/", views.google_login),
    path("auth/me/", views.me),
    path("auth/logout/", views.logout_view),
]
