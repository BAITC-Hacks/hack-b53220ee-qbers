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
    path("safety/", views.safety_data),
    path("safety/scenario/", views.safety_scenario),
    path("districts/", views.districts_data),
    path("education/", views.education_data),
    path("education/scenario/", views.education_scenario),
    path("cityservices/", views.cityservices_data),
    path("cityservices/scenario/", views.cityservices_scenario),
    path("score/", views.score_data),
    path("ai/allocate/", views.ai_allocate),
    path("ai/report/", views.ai_report),
    path("translate/", views.translate_view),
    path("auth/google/", views.google_login),
    path("auth/me/", views.me),
    path("auth/logout/", views.logout_view),
]
