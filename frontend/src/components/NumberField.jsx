import { useEffect, useState } from "react";

// Numeric input that lets people type freely ("12", "12.", "") and reports clean
// numbers upward. Shows thousands separators when not focused.
export default function NumberField({ value, onChange, decimals = 2, suffix, prefix, ariaLabel, invalid }) {
  const [focused, setFocused] = useState(false);
  const [text, setText] = useState(String(value));

  useEffect(() => {
    if (!focused) setText(String(value));
  }, [value, focused]);

  const fractional = decimals > 0 && !Number.isInteger(Number(value));
  const display = focused
    ? text
    : Number(value).toLocaleString("en-US", { minimumFractionDigits: fractional ? decimals : 0, maximumFractionDigits: decimals });

  return (
    <label className={`number-field ${invalid ? "is-invalid" : ""}`}>
      {prefix && <span className="affix">{prefix}</span>}
      <input
        inputMode="decimal"
        aria-label={ariaLabel}
        value={display}
        onFocus={() => {
          setFocused(true);
          setText(String(value));
        }}
        onBlur={() => setFocused(false)}
        onChange={(e) => {
          const raw = e.target.value.replace(/[,\s]/g, "");
          if (raw !== "" && !/^\d*\.?\d*$/.test(raw)) return;
          setText(raw);
          const n = Number(raw);
          if (raw === "" || Number.isFinite(n)) onChange(raw === "" ? 0 : Math.round(n * 10 ** decimals) / 10 ** decimals);
        }}
      />
      {suffix && <span className="affix">{suffix}</span>}
    </label>
  );
}
