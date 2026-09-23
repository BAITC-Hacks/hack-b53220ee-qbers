import json
from datetime import timedelta

import django
import requests
from django.conf import settings
from django.contrib.auth import get_user_model, login, logout
from django.db import connection
from django.http import JsonResponse
from django.utils import timezone
from django.utils.dateparse import parse_datetime
from django.views.decorators.csrf import ensure_csrf_cookie
from django.views.decorators.http import require_GET, require_http_methods, require_POST
from google.auth.transport import requests as google_requests
from google.oauth2 import id_token

from .budget import DEFAULT_MONEY_TOTAL, DEFAULT_UNITS_TOTAL, default_section
from .forms import BudgetPlanForm
from .models import BudgetPlan, ExchangeRates


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
    except Exception as exc:  # surface the reason on the page
        db_version, db_ok = str(exc), False
    return JsonResponse(
        {
            "django": django.get_version(),
            "database": {
                "ok": db_ok,
                "version": db_version,
                "host": f"{settings.DATABASES['default']['HOST']}:{settings.DATABASES['default']['PORT']}",
                "name": settings.DATABASES["default"]["NAME"],
            },
            "currency_api_key_loaded": bool(settings.CURRENCYAPI_KEY),
        }
    )


@require_GET
@ensure_csrf_cookie
def csrf(request):
    return JsonResponse({"ok": True})


# ---------------------------------------------------------------------------
# Budget plan — one current plan, validated by BudgetPlanForm, stored in Postgres
# ---------------------------------------------------------------------------
def _current_plan():
    plan = BudgetPlan.objects.order_by("-updated_at").first()
    if plan is None:
        plan = BudgetPlan.objects.create(
            money=_stringify(default_section(DEFAULT_MONEY_TOTAL, 2)),
            units=_stringify(default_section(DEFAULT_UNITS_TOTAL, 0)),
        )
    return plan


def _stringify(section):
    return {
        "total": str(section["total"]),
        "split": section["split"],
        "allocations": {k: str(v) for k, v in section["allocations"].items()},
    }


def _plan_payload(plan):
    return {
        "mode": plan.mode,
        "currency": plan.currency,
        "money": plan.money,
        "units": plan.units,
        "updated_at": plan.updated_at.isoformat(),
    }


@require_http_methods(["GET", "PUT"])
def plan(request):
    current = _current_plan()
    if request.method == "PUT":
        form = BudgetPlanForm(_json_body(request))
        if not form.is_valid():
            errors = [e for field in form.errors.values() for e in field]
            return JsonResponse({"error": " ".join(errors), "errors": form.errors}, status=400)
        for field in ("mode", "currency", "money", "units"):
            setattr(current, field, form.cleaned_data[field])
        current.save()
    return JsonResponse(_plan_payload(current))


# ---------------------------------------------------------------------------
# Currency rates — proxied so the key stays server-side, cached to save quota
# ---------------------------------------------------------------------------
def _rates_payload(snapshot, cached, warning=None):
    body = {
        "base": snapshot.base,
        "rates": {**snapshot.rates, snapshot.base: 1},
        "source_updated_at": snapshot.source_updated_at.isoformat() if snapshot.source_updated_at else None,
        "fetched_at": snapshot.fetched_at.isoformat(),
        "cached": cached,
    }
    if warning:
        body["warning"] = warning
    return body


@require_GET
def currency(request):
    latest = ExchangeRates.objects.filter(base="KZT").order_by("-fetched_at").first()
    max_age = timedelta(hours=settings.CURRENCY_CACHE_HOURS)
    if latest and timezone.now() - latest.fetched_at < max_age:
        return JsonResponse(_rates_payload(latest, cached=True))
    if not settings.CURRENCYAPI_KEY:
        if latest:
            return JsonResponse(_rates_payload(latest, cached=True, warning="CURRENCYAPI_KEY missing; using saved rates."))
        return JsonResponse({"error": "CURRENCYAPI_KEY is not set in .env."}, status=503)
    try:
        res = requests.get(
            "https://api.currencyapi.com/v3/latest",
            params={"apikey": settings.CURRENCYAPI_KEY, "base_currency": "KZT"},
            timeout=10,
        )
        res.raise_for_status()
        body = res.json()
        rates = {code: item["value"] for code, item in body["data"].items()}
    except (requests.RequestException, KeyError, ValueError) as exc:
        if latest:  # stale beats nothing
            return JsonResponse(_rates_payload(latest, cached=True, warning=f"Live rates unavailable ({exc}); using saved rates."))
        return JsonResponse({"error": f"Could not load exchange rates: {exc}"}, status=502)
    snapshot = ExchangeRates.objects.create(
        base="KZT", rates=rates, source_updated_at=parse_datetime(body.get("meta", {}).get("last_updated_at", "") or "")
    )
    return JsonResponse(_rates_payload(snapshot, cached=False))


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
