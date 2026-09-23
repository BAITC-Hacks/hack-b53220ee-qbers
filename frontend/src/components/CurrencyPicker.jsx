import { useEffect, useId, useMemo, useRef, useState } from "react";
import { currencyName } from "../lib/money";
import "./CurrencyPicker.css";

const flags = import.meta.glob("../assets/currency-flags/*.svg", { eager: true, query: "?url&no-inline", import: "default" });
const officialCurrencies = new Set(Intl.supportedValuesOf("currency"));

function CurrencyFlag({ code }) {
  const country = code === "EUR" ? "eu" : code.slice(0, 2).toLowerCase();
  const flag = officialCurrencies.has(code) && !code.startsWith("X") ? flags[`../assets/currency-flags/${country}.svg`] : null;
  return flag ? <img className="currency-flag" src={flag} alt="" width="24" height="24" /> : (
    <span className="currency-flag currency-flag-neutral" aria-hidden="true">
      <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="1.5"><circle cx="12" cy="12" r="9" /><ellipse cx="12" cy="12" rx="4" ry="9" /><path d="M3 12h18M5 6.5h14M5 17.5h14" /></svg>
    </span>
  );
}

export default function CurrencyPicker({ value, pinned, others, disabled, onChange }) {
  const [open, setOpen] = useState(false);
  const [search, setSearch] = useState("");
  const [active, setActive] = useState(value);
  const root = useRef(null);
  const trigger = useRef(null);
  const input = useRef(null);
  const list = useRef(null);
  const id = useId();
  const groups = useMemo(() => [
    { label: "Common", codes: pinned }, { label: "All currencies", codes: others },
  ].map((group) => ({ ...group, codes: group.codes.filter((code) => `${code} ${currencyName(code)}`.toLowerCase().includes(search.trim().toLowerCase())) })), [pinned, others, search]);
  const visible = groups.flatMap((group) => group.codes);
  const activeCode = visible.includes(active) ? active : visible[0];

  useEffect(() => {
    if (!open) return;
    input.current?.focus();
    const close = (event) => { if (!root.current?.contains(event.target)) setOpen(false); };
    document.addEventListener("pointerdown", close);
    return () => document.removeEventListener("pointerdown", close);
  }, [open]);
  useEffect(() => {
    if (open) list.current?.querySelector('[data-active="true"]')?.scrollIntoView({ block: "nearest" });
  }, [open, activeCode]);
  useEffect(() => { if (disabled) setOpen(false); }, [disabled]);

  function show() { setSearch(""); setActive(value); setOpen(true); }
  function choose(code) {
    if (!code) return;
    onChange(code);
    setOpen(false);
    trigger.current?.focus();
  }
  function onKeyDown(event) {
    if (event.key === "Escape") { event.preventDefault(); setOpen(false); trigger.current?.focus(); return; }
    if (!open) {
      if (["ArrowDown", "ArrowUp"].includes(event.key) && !disabled) { event.preventDefault(); show(); }
      return;
    }
    const index = visible.indexOf(activeCode);
    if (event.key === "ArrowDown" || event.key === "ArrowUp") {
      event.preventDefault();
      const next = (index + (event.key === "ArrowDown" ? 1 : -1) + visible.length) % visible.length;
      setActive(visible[next]);
    } else if (event.key === "Enter") { event.preventDefault(); choose(activeCode); }
  }

  return <div className="currency-picker" ref={root} onKeyDown={onKeyDown}
    onBlur={(event) => { if (!event.currentTarget.contains(event.relatedTarget)) setOpen(false); }}>
    <button ref={trigger} className="currency-trigger" type="button" disabled={disabled} aria-label={`Currency: ${value} — ${currencyName(value)}`}
      aria-haspopup="listbox" aria-expanded={open} aria-controls={open ? id : undefined} onClick={() => open ? setOpen(false) : show()}>
      <CurrencyFlag code={value} />
      <span className="currency-label"><strong>{value}</strong><span>{currencyName(value)}</span></span>
      <svg width="14" height="14" viewBox="0 0 16 16" aria-hidden="true"><path d="m4 6 4 4 4-4" fill="none" stroke="currentColor" strokeWidth="1.6" /></svg>
    </button>
    {open && <div className="currency-popup">
      <input ref={input} className="currency-search" type="search" role="combobox" aria-label="Search currencies" placeholder="Search currencies…"
        aria-expanded="true" aria-controls={id} aria-autocomplete="list" aria-activedescendant={activeCode ? `${id}-${activeCode}` : undefined}
        value={search} onChange={(event) => setSearch(event.target.value)} />
      <div ref={list} id={id} className="currency-options" role="listbox" aria-label="Currencies">
        {groups.filter((group) => group.codes.length).map((group) => <div role="group" aria-label={group.label} key={group.label}>
          <div className="currency-group-label" aria-hidden="true">{group.label}</div>
          {group.codes.map((code) => <div key={code} id={`${id}-${code}`} className="currency-option" role="option"
            aria-selected={code === value} data-active={code === activeCode} onMouseDown={(event) => event.preventDefault()} onClick={() => choose(code)}>
            <CurrencyFlag code={code} /><span className="currency-label"><strong>{code}</strong><span>{currencyName(code)}</span></span>
            {code === value && <span className="currency-check" aria-hidden="true">✓</span>}
          </div>)}
        </div>)}
      </div>
      {!visible.length && <p className="currency-empty" role="status">No currencies found</p>}
    </div>}
  </div>;
}
