"""Translation proxy: Google Cloud Translation API v2, called server-side so the
Google API key never reaches the browser. Results are cached in Postgres — a batch
of UI strings costs real money only the first time any teammate sees it."""
import hashlib

import requests
from django.conf import settings

from .models import TranslationCache

TRANSLATE_URL = "https://translation.googleapis.com/language/translate/v2"
LANGUAGES = {"kk": "Kazakh", "ru": "Russian", "zh-CN": "Chinese (Simplified)"}


def _hash(text):
    return hashlib.sha256(text.encode("utf-8")).hexdigest()


def translate_batch(texts, target):
    """Returns (translations_in_order, error). On error, translations is None."""
    if target not in LANGUAGES:
        return None, f"Unsupported target language '{target}'."
    if not settings.GOOGLE_API_KEY:
        return None, "GOOGLE_API_KEY is not set in .env."

    unique = list(dict.fromkeys(t for t in texts if t and t.strip()))
    hashes = {t: _hash(t) for t in unique}
    cached = {
        c.text_hash: c.translated_text
        for c in TranslationCache.objects.filter(target=target, text_hash__in=hashes.values())
    }
    missing = [t for t in unique if hashes[t] not in cached]

    if missing:
        try:
            res = requests.post(
                TRANSLATE_URL,
                params={"key": settings.GOOGLE_API_KEY},
                json={"q": missing, "target": target, "source": "en", "format": "text"},
                timeout=20,
            )
        except requests.RequestException as exc:
            return None, f"Could not reach Google Translate: {exc}"
        if res.status_code != 200:
            reason = res.json().get("error", {}).get("message", res.text[:200]) if res.content else res.reason
            hint = ""
            if res.status_code in (400, 403):
                hint = " Enable 'Cloud Translation API' for this key's project in Google Cloud Console."
            return None, f"Google Translate returned HTTP {res.status_code}: {reason}.{hint}"
        translations = res.json()["data"]["translations"]
        new_rows = []
        for text, item in zip(missing, translations):
            translated = item["translatedText"]
            cached[hashes[text]] = translated
            new_rows.append(TranslationCache(target=target, text_hash=hashes[text], source_text=text[:8000], translated_text=translated))
        TranslationCache.objects.bulk_create(new_rows, ignore_conflicts=True)

    return {t: cached[hashes[t]] for t in unique}, None
