from django.urls import path

from . import views

urlpatterns = [
    path("health/", views.health),
    path("csrf/", views.csrf),
    path("plan/", views.plan),
    path("currency/", views.currency),
    path("auth/google/", views.google_login),
    path("auth/me/", views.me),
    path("auth/logout/", views.logout_view),
]
