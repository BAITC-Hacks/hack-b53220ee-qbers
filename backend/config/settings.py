"""Django settings for the HackAlem / QBERS backend.

Every secret and environment-specific value comes from the repo-root `.env`
file, plus `.env.local` for personal overrides. Nothing sensitive is hard-coded here.
"""
import os
from pathlib import Path

from dotenv import load_dotenv

BASE_DIR = Path(__file__).resolve().parent.parent
REPO_ROOT = BASE_DIR.parent
# Priority: real environment > .env.local (personal, gitignored) > .env (team).
load_dotenv(REPO_ROOT / ".env.local")
load_dotenv(REPO_ROOT / ".env")


def env(name, default=""):
    return os.environ.get(name, default)


def env_bool(name, default=False):
    return env(name, str(default)).lower() in {"1", "true", "yes", "on"}


SECRET_KEY = env("DJANGO_SECRET_KEY")
DEBUG = env_bool("DJANGO_DEBUG", True)
ALLOWED_HOSTS = [h for h in env("DJANGO_ALLOWED_HOSTS", "localhost,127.0.0.1").split(",") if h]

FRONTEND_ORIGIN = env("FRONTEND_ORIGIN", "http://localhost:5173")
CSRF_TRUSTED_ORIGINS = [FRONTEND_ORIGIN, "http://127.0.0.1:5173"]

INSTALLED_APPS = [
    "django.contrib.admin",
    "django.contrib.auth",
    "django.contrib.contenttypes",
    "django.contrib.sessions",
    "django.contrib.messages",
    "django.contrib.staticfiles",
    "core",
]

MIDDLEWARE = [
    "django.middleware.security.SecurityMiddleware",
    "django.middleware.gzip.GZipMiddleware",  # map payloads shrink ~5×
    "django.contrib.sessions.middleware.SessionMiddleware",
    "django.middleware.common.CommonMiddleware",
    "django.middleware.csrf.CsrfViewMiddleware",
    "django.contrib.auth.middleware.AuthenticationMiddleware",
    "django.contrib.messages.middleware.MessageMiddleware",
    "django.middleware.clickjacking.XFrameOptionsMiddleware",
]

ROOT_URLCONF = "config.urls"

TEMPLATES = [
    {
        "BACKEND": "django.template.backends.django.DjangoTemplates",
        "DIRS": [],
        "APP_DIRS": True,
        "OPTIONS": {
            "context_processors": [
                "django.template.context_processors.request",
                "django.contrib.auth.context_processors.auth",
                "django.contrib.messages.context_processors.messages",
            ],
        },
    },
]

WSGI_APPLICATION = "config.wsgi.application"

# PostgreSQL runs in Docker (docker-compose.yml); connection details live in .env.
DATABASES = {
    "default": {
        "ENGINE": "django.db.backends.postgresql",
        "NAME": env("POSTGRES_DB"),
        "USER": env("POSTGRES_USER"),
        "PASSWORD": env("POSTGRES_PASSWORD"),
        "HOST": env("POSTGRES_HOST", "127.0.0.1"),
        "PORT": env("POSTGRES_PORT"),
    }
}

AUTH_PASSWORD_VALIDATORS = [
    {"NAME": "django.contrib.auth.password_validation.UserAttributeSimilarityValidator"},
    {"NAME": "django.contrib.auth.password_validation.MinimumLengthValidator"},
    {"NAME": "django.contrib.auth.password_validation.CommonPasswordValidator"},
    {"NAME": "django.contrib.auth.password_validation.NumericPasswordValidator"},
]

LANGUAGE_CODE = "en-us"
TIME_ZONE = "UTC"
USE_I18N = True
USE_TZ = True

STATIC_URL = "static/"
DEFAULT_AUTO_FIELD = "django.db.models.BigAutoField"

# Google — the OAuth client secret stays server-side only.
GOOGLE_API_KEY = env("GOOGLE_API_KEY")
GOOGLE_OAUTH_CLIENT_ID = env("GOOGLE_OAUTH_CLIENT_ID")
GOOGLE_OAUTH_CLIENT_SECRET = env("GOOGLE_OAUTH_CLIENT_SECRET")

# Currency conversion (currencyapi.com). Free plan = 300 calls/month, so rates are
# cached in Postgres and refreshed at most every CURRENCY_CACHE_HOURS.
CURRENCYAPI_KEY = env("CURRENCYAPI_KEY")
CURRENCY_CACHE_HOURS = int(env("CURRENCY_CACHE_HOURS", "12"))

# 2GIS catalog API — used only by `manage.py build_open_data` to download stations.
DGIS_API_KEY = env("DGIS_API_KEY")

# AWS — read here so future boto3 code has one place to pull from.
AWS_CONSOLE_URL = env("AWS_CONSOLE_URL")
AWS_CONSOLE_USERNAME = env("AWS_CONSOLE_USERNAME")
AWS_CONSOLE_PASSWORD = env("AWS_CONSOLE_PASSWORD")
AWS_ACCESS_KEY_ID = env("AWS_ACCESS_KEY_ID")
AWS_SECRET_ACCESS_KEY = env("AWS_SECRET_ACCESS_KEY")
AWS_REGION = env("AWS_REGION", "us-east-1")
