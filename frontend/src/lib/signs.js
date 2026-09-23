// Map/legend signs as inline SVG data URLs (no extra image files to ship).
const svg = (body, { ring } = {}) =>
  `data:image/svg+xml;charset=utf-8,${encodeURIComponent(
    `<svg xmlns="http://www.w3.org/2000/svg" width="40" height="40" viewBox="0 0 40 40">${
      ring ? '<rect x="1" y="1" width="38" height="38" rx="11" fill="#FFFACD" stroke="#006A6D" stroke-width="2" stroke-dasharray="4 3"/>' : ""
    }${body}</svg>`
  )}`;

const busGlyph = (bg) => `
  <rect x="5" y="5" width="30" height="30" rx="8" fill="${bg}" stroke="#fff" stroke-width="2.5"/>
  <rect x="11" y="11" width="18" height="15" rx="3" fill="#fff"/>
  <rect x="13" y="13" width="14" height="6" rx="1.5" fill="${bg}"/>
  <circle cx="14.5" cy="23" r="1.6" fill="${bg}"/><circle cx="25.5" cy="23" r="1.6" fill="${bg}"/>
  <rect x="12.5" y="26" width="3" height="3" rx="1" fill="#fff"/><rect x="24.5" y="26" width="3" height="3" rx="1" fill="#fff"/>`;

const trainGlyph = (bg) => `
  <rect x="5" y="5" width="30" height="30" rx="8" fill="${bg}" stroke="#fff" stroke-width="2.5"/>
  <rect x="12" y="9" width="16" height="17" rx="5" fill="#fff"/>
  <rect x="14.5" y="12" width="11" height="5.5" rx="1.5" fill="${bg}"/>
  <circle cx="16" cy="21.5" r="1.5" fill="${bg}"/><circle cx="24" cy="21.5" r="1.5" fill="${bg}"/>
  <path d="M14 26l-3 5M26 26l3 5M13 29.5h14" stroke="#fff" stroke-width="2" stroke-linecap="round"/>`;

export const SIGN_COLORS = { bus: "#1565C0", rail: "#2E7D32", lrt: "#6A1B9A" };

// Small dot used for bus stops when zoomed out, so route lines stay visible.
const dot = (bg) =>
  `data:image/svg+xml;charset=utf-8,${encodeURIComponent(
    `<svg xmlns="http://www.w3.org/2000/svg" width="12" height="12" viewBox="0 0 12 12"><circle cx="6" cy="6" r="4.5" fill="${bg}" stroke="#fff" stroke-width="1.5"/></svg>`
  )}`;

export const SIGNS = {
  busDot: dot(SIGN_COLORS.bus),
  bus: svg(busGlyph(SIGN_COLORS.bus)),
  rail: svg(trainGlyph(SIGN_COLORS.rail)),
  lrt: svg(trainGlyph(SIGN_COLORS.lrt)),
  newBus: svg(busGlyph(SIGN_COLORS.bus), { ring: true }),
  newRail: svg(trainGlyph(SIGN_COLORS.rail), { ring: true }),
};
