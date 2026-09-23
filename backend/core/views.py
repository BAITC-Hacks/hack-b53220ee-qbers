import json

import django
from django.conf import settings
from django.contrib.auth import get_user_model, login, logout
from django.db import connection
from django.http import JsonResponse
from django.views.decorators.csrf import ensure_csrf_cookie
from django.views.decorators.http import require_GET, require_POST
from google.auth.transport import requests as google_requests
from google.oauth2 import id_token

from .forms import WaitlistForm
from .models import Location, Metric, WaitlistSignup


def _json_body(request):
    try:
        return json.loads(request.body or b"{}")
    except json.JSONDecodeError:
        return {}


def _user_payload(user):
    if not user.is_authenticated:
        return None
    return {"email": user.email, "name": user.get_full_name() or user.username}


@require_GET
def health(request):
    try:
        with connection.cursor() as cursor:
            cursor.execute("SELECT version()")
            db_version = cursor.fetchone()[0].split(",")[0]
        db_ok = True
    except Exception as exc:  # surface the reason on the landing page
        db_version, db_ok = str(exc), False
    return JsonResponse(
        {
            "django": django.get_version(),
            "database": {"ok": db_ok, "version": db_version},
            "google_api_key_loaded": bool(settings.GOOGLE_API_KEY),
            "google_oauth_loaded": bool(settings.GOOGLE_OAUTH_CLIENT_ID and settings.GOOGLE_OAUTH_CLIENT_SECRET),
        }
    )


@require_GET
@ensure_csrf_cookie
def csrf(request):
    return JsonResponse({"ok": True})


@require_GET
def stats(request):
    rows = [[m.label, m.users, m.requests] for m in Metric.objects.all()]
    return JsonResponse({"columns": ["Month", "Users", "API requests"], "rows": rows})


@require_GET
def locations(request):
    return JsonResponse({"locations": list(Location.objects.values("name", "lat", "lng"))})


def waitlist(request):
    if request.method == "POST":
        form = WaitlistForm(_json_body(request))
        if not form.is_valid():
            return JsonResponse({"errors": form.errors}, status=400)
        form.save()
    return JsonResponse({"count": WaitlistSignup.objects.count()})


@require_POST
def google_login(request):
    credential = _json_body(request).get("credential")
    if not credential:
        return JsonResponse({"error": "Missing credential"}, status=400)
    try:
        info = id_token.verify_oauth2_token(
            credential, google_requests.Request(), settings.GOOGLE_OAUTH_CLIENT_ID
        )
    except ValueError as exc:
        return JsonResponse({"error": f"Invalid Google token: {exc}"}, status=401)

    User = get_user_model()
    user, _ = User.objects.get_or_create(
        username=info["email"],
        defaults={
            "email": info["email"],
            "first_name": info.get("given_name", ""),
            "last_name": info.get("family_name", ""),
        },
    )
    login(request, user)
    return JsonResponse({"user": _user_payload(user), "picture": info.get("picture")})


@require_GET
def me(request):
    return JsonResponse({"user": _user_payload(request.user)})


@require_POST
def logout_view(request):
    logout(request)
    return JsonResponse({"ok": True})
