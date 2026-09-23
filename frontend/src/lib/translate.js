// Whole-page machine translation via Google Cloud Translation API (server-proxied — see
// core/translate.py). Rather than wrapping every string in the app in a t()/i18n call
// (thousands of strings across a dozen components), this walks the rendered DOM for text
// nodes and translates them in place, the same technique browser "translate this page"
// tools use. English is always the source of truth: we remember each node's original
// English text, so switching languages (including back to English) never needs a reload.
import { api } from "./api";

export const LANGUAGES = [
  { code: "en", label: "English", native: "English" },
  { code: "kk", label: "Kazakh", native: "Қазақша" },
  { code: "ru", label: "Russian", native: "Русский" },
  { code: "zh-CN", label: "Chinese", native: "中文" },
];

// Elements whose text should never be machine-translated: user-entered numbers, code,
// external links/citations, proper nouns from the data (district names, sources), and
// anything explicitly marked. NOTE: we deliberately stop walking ancestors at <body> —
// <html> always carries the *target* `lang` (set by the switcher itself), so checking it
// with Element.closest() would match every single node on the page and skip everything.
const SKIP_SELECTOR = "code, [data-no-translate], [lang]:not([lang='en']), script, style, textarea, .cost-input input, .number-field input, .sources, .region-kk";
const MOSTLY_NON_LETTERS = /^[\s\d.,:;/%$₸€£¥+\-()#*→↑↓·•–—]*$/;

const originals = new WeakMap(); // Text node -> original English string
let currentLang = "en";
let observer = null;
let pending = new Set();
let flushTimer = null;

function withinSkippedAncestor(el) {
  for (let node = el; node && node !== document.body; node = node.parentElement) {
    if (node.matches?.(SKIP_SELECTOR)) return true;
  }
  return false;
}

function isTranslatable(node) {
  const text = node.nodeValue;
  if (!text || !text.trim() || MOSTLY_NON_LETTERS.test(text)) return false;
  const el = node.parentElement;
  if (!el) return false;
  return !withinSkippedAncestor(el);
}

function collectTextNodes(root) {
  const walker = document.createTreeWalker(root, NodeFilter.SHOW_TEXT, null);
  const nodes = [];
  let n;
  while ((n = walker.nextNode())) if (isTranslatable(n)) nodes.push(n);
  return nodes;
}

async function translateNodes(nodes, lang) {
  const unique = [...new Set(nodes.map((n) => originals.get(n) ?? n.nodeValue))];
  if (!unique.length) return { ok: true };
  try {
    const { translations } = await api("translate/", { method: "POST", body: { texts: unique, target: lang } });
    for (const node of nodes) {
      if (currentLang !== lang) return { ok: true }; // language changed again mid-flight
      const original = originals.get(node) ?? node.nodeValue;
      if (!originals.has(node)) originals.set(node, original);
      const translated = translations[original];
      if (translated) node.nodeValue = translated;
    }
    return { ok: true };
  } catch (e) {
    return { ok: false, error: e.data?.error || e.message };
  }
}

function restoreOriginals(root) {
  for (const node of collectTextNodes(root)) {
    const original = originals.get(node);
    if (original != null) node.nodeValue = original;
  }
}

function scheduleFlush(root, lang, onError) {
  clearTimeout(flushTimer);
  flushTimer = setTimeout(async () => {
    const nodes = [...pending];
    pending = new Set();
    if (!nodes.length) return;
    const res = await translateNodes(nodes, lang);
    if (!res.ok) onError?.(res.error);
  }, 250);
}

/**
 * Start (or stop) translating `root`'s content into `lang`. Call again whenever `lang`
 * changes; call with "en" to restore the original text. Returns a cleanup function.
 */
export function watchAndTranslate(root, lang, onError) {
  currentLang = lang;
  observer?.disconnect();
  pending = new Set();
  clearTimeout(flushTimer);

  if (lang === "en") {
    restoreOriginals(root);
    return () => {};
  }

  const queueAll = () => {
    for (const node of collectTextNodes(root)) pending.add(node);
    scheduleFlush(root, lang, onError);
  };
  queueAll(); // translate what's already on screen

  // React re-renders tabs/panels as new DOM — catch newly added text as it appears.
  observer = new MutationObserver((mutations) => {
    if (currentLang !== lang) return;
    for (const m of mutations) {
      for (const added of m.addedNodes) {
        if (added.nodeType === Node.TEXT_NODE) {
          if (isTranslatable(added)) pending.add(added);
        } else if (added.nodeType === Node.ELEMENT_NODE) {
          collectTextNodes(added).forEach((n) => pending.add(n));
        }
      }
      if (m.type === "characterData" && m.target.nodeType === Node.TEXT_NODE) {
        // Only re-queue if this text wasn't just our own translation landing.
        if (isTranslatable(m.target) && !originals.has(m.target)) pending.add(m.target);
      }
    }
    if (pending.size) scheduleFlush(root, lang, onError);
  });
  observer.observe(root, { childList: true, subtree: true, characterData: true });

  return () => observer?.disconnect();
}
