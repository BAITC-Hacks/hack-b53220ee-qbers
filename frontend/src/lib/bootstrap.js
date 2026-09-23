import { env } from "./env";
import { loadScript } from "./loadScript";

// Google Fonts — families come from VITE_FONT_SANS / VITE_FONT_SERIF.
export function loadFonts() {
  const family = (name, axes) => `family=${name.trim().replace(/ /g, "+")}:${axes}`;
  const href =
    "https://fonts.googleapis.com/css2?" +
    [family(env.fontSans, "wght@300;400;500;700;900"), family(env.fontSerif, "ital,wght@0,400;0,600;1,400")].join("&") +
    "&display=swap";
  const link = Object.assign(document.createElement("link"), { rel: "stylesheet", href });
  document.head.appendChild(link);
  const root = document.documentElement.style;
  root.setProperty("--font-sans", `"${env.fontSans}", system-ui, sans-serif`);
  root.setProperty("--font-serif", `"${env.fontSerif}", Garamond, Georgia, serif`);
}

// Google Analytics 4 — only runs when VITE_GA_MEASUREMENT_ID (G-XXXXXXX) is set.
export function loadAnalytics() {
  const id = env.gaMeasurementId;
  if (!id) return;
  window.dataLayer = window.dataLayer || [];
  window.gtag = function gtag() {
    window.dataLayer.push(arguments);
  };
  window.gtag("js", new Date());
  window.gtag("config", id);
  loadScript(`https://www.googletagmanager.com/gtag/js?id=${id}`);
}
