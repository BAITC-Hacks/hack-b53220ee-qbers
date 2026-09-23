import { AREA_IDS } from "./areas";

export const DECIMALS = { money: 2, units: 0 };
export const PINNED_CURRENCIES = ["KZT", "USD", "EUR", "RUB", "CNY", "GBP", "TRY", "AED", "KGS", "UZS"];

// Split `total` into equal parts that add up exactly — same rule as the backend.
export function equalSplit(total, decimals) {
  const scale = 10 ** decimals;
  const cents = Math.round(total * scale);
  const base = Math.floor(cents / AREA_IDS.length);
  let remainder = cents - base * AREA_IDS.length;
  return Object.fromEntries(AREA_IDS.map((id) => [id, (base + (remainder-- > 0 ? 1 : 0)) / scale]));
}

export const sumOf = (allocations) => AREA_IDS.reduce((sum, id) => sum + (allocations[id] || 0), 0);

// rates are "units of currency per 1 KZT" (currencyapi with base KZT).
export function convert(value, from, to, rates) {
  if (from === to || !rates?.[from] || !rates?.[to]) return value;
  return (value / rates[from]) * rates[to];
}

export const round = (value, decimals) => Math.round(value * 10 ** decimals) / 10 ** decimals;

export function formatAmount(value, { mode, currency, compact = false }) {
  if (mode === "units") {
    const n = new Intl.NumberFormat("en-US", { notation: compact ? "compact" : "standard", maximumFractionDigits: compact ? 1 : 0 }).format(value);
    return `${n} ${value === 1 ? "unit" : "units"}`;
  }
  try {
    return new Intl.NumberFormat("en-US", {
      style: "currency",
      currency,
      currencyDisplay: "narrowSymbol",
      notation: compact ? "compact" : "standard",
      minimumFractionDigits: 0, // ₸200,000,000 rather than ₸200,000,000.00
      maximumFractionDigits: compact ? 1 : 2,
    }).format(value);
  } catch {
    return `${value.toLocaleString("en-US")} ${currency}`;
  }
}

// currencyapi also returns crypto tickers (e.g. "1INCH"); only real 3-letter currency codes are offered.
export const isCurrencyCode = (code) => /^[A-Z]{3}$/.test(code);

const names = typeof Intl.DisplayNames === "function" ? new Intl.DisplayNames(["en"], { type: "currency" }) : null;
export function currencyName(code) {
  try {
    return names?.of(code) || code;
  } catch {
    return code;
  }
}

// API <-> UI: the backend stores decimals as strings.
export function sectionFromApi(section) {
  return {
    total: Number(section.total),
    split: section.split,
    allocations: Object.fromEntries(AREA_IDS.map((id) => [id, Number(section.allocations[id] || 0)])),
  };
}

export function sectionToApi(section, decimals) {
  return {
    total: section.total.toFixed(decimals),
    split: section.split,
    allocations: Object.fromEntries(AREA_IDS.map((id) => [id, section.allocations[id].toFixed(decimals)])),
  };
}
