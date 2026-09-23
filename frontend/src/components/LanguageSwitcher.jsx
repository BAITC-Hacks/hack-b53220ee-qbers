import { useEffect, useRef, useState } from "react";
import { LANGUAGES, watchAndTranslate } from "../lib/translate";

const STORAGE_KEY = "hackalem.lang";

export default function LanguageSwitcher() {
  const [lang, setLang] = useState(() => {
    try {
      return localStorage.getItem(STORAGE_KEY) || "en";
    } catch {
      return "en";
    }
  });
  const [error, setError] = useState(null);
  const [busy, setBusy] = useState(false);

  useEffect(() => {
    document.documentElement.lang = lang === "zh-CN" ? "zh" : lang;
    setError(null);
    setBusy(lang !== "en");
    const stop = watchAndTranslate(document.body, lang, (message) => {
      setError(message);
      setBusy(false);
    });
    // No reliable "finished" signal from a live DOM watcher — clear the busy flag shortly
    // after the initial pass would have gone out.
    const t = setTimeout(() => setBusy(false), 900);
    return () => {
      stop();
      clearTimeout(t);
    };
  }, [lang]);

  function onChange(e) {
    const code = e.target.value;
    setLang(code);
    try {
      localStorage.setItem(STORAGE_KEY, code);
    } catch {
      /* private browsing — the choice just won't persist */
    }
  }

  return (
    <div className="lang-switcher" data-no-translate>
      <label className="lang-select">
        <i className={`fa-solid ${busy ? "fa-spinner fa-spin" : "fa-language"}`} />
        <select value={lang} onChange={onChange} aria-label="Language" title="Original language: English. Other languages are machine-translated.">
          {LANGUAGES.map((l) => (
            <option key={l.code} value={l.code}>
              {l.native}{l.code === "en" ? " (original)" : ""}
            </option>
          ))}
        </select>
      </label>
      {error && (
        <span className="lang-error" title={error} role="status">
          <i className="fa-solid fa-triangle-exclamation" /> Translation unavailable
        </span>
      )}
    </div>
  );
}
