// Map/legend signs as inline SVG data URLs (no extra image files to ship).
const svg = (body, { ring } = {}) =>
  `data:image/svg+xml;charset=utf-8,${encodeURIComponent(
    `<svg xmlns="http://www.w3.org/2000/svg" width="40" height="40" viewBox="0 0 40 40">${
      ring ? '<rect x="1" y="1" width="38" height="38" rx="2" fill="#FFFACD" stroke="#006A6D" stroke-width="2" stroke-dasharray="4 3"/>' : ""
    }${body}</svg>`
  )}`;

const busGlyph = (bg) => `
  <rect x="5" y="5" width="30" height="30" rx="2" fill="${bg}" stroke="#fff" stroke-width="2.5"/>
  <rect x="11" y="11" width="18" height="15" rx="3" fill="#fff"/>
  <rect x="13" y="13" width="14" height="6" rx="1.5" fill="${bg}"/>
  <circle cx="14.5" cy="23" r="1.6" fill="${bg}"/><circle cx="25.5" cy="23" r="1.6" fill="${bg}"/>
  <rect x="12.5" y="26" width="3" height="3" rx="1" fill="#fff"/><rect x="24.5" y="26" width="3" height="3" rx="1" fill="#fff"/>`;

const trainGlyph = (bg) => `
  <rect x="5" y="5" width="30" height="30" rx="2" fill="${bg}" stroke="#fff" stroke-width="2.5"/>
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

// ---------------------------------------------------------------------------
// Safety signs (square, like the transport signs)
// ---------------------------------------------------------------------------
const square = (bg, glyph, { ring } = {}) => svg(`<rect x="5" y="5" width="30" height="30" rx="2" fill="${bg}" stroke="#fff" stroke-width="2.5"/>${glyph}`, { ring });
const GLYPHS = {
  fire: '<path d="M20 10c1 4 6 6 6 12a6 6 0 0 1-12 0c0-3 2-4 2-7 2 1 3 3 3 5 1-2 1-6 1-10z" fill="#fff"/>',
  police: '<path d="M20 10l8 3v6c0 5-3.5 8.5-8 10-4.5-1.5-8-5-8-10v-6z" fill="#fff"/><path d="M20 15l1.3 2.7 3 .4-2.2 2.1.5 3-2.6-1.4-2.6 1.4.5-3-2.2-2.1 3-.4z" fill="currentColor"/>',
  post: '<path d="M20 11l7 2.6v5.4c0 4.4-3 7.4-7 8.8-4-1.4-7-4.4-7-8.8v-5.4z" fill="#fff"/>',
  lamp: '<path d="M16 12h8l-1.5 5h-5z" fill="#fff"/><circle cx="20" cy="20" r="3" fill="#fff"/><rect x="19" y="23" width="2" height="7" fill="#fff"/><rect x="16" y="29" width="8" height="2" fill="#fff"/>',
  speed: '<rect x="12" y="13" width="13" height="10" rx="1" fill="#fff"/><circle cx="18.5" cy="18" r="3" fill="currentColor"/><path d="M25 16l4-2v8l-4-2z" fill="#fff"/><rect x="17" y="23" width="3" height="6" fill="#fff"/>',
  cctv: '<path d="M11 15l14-4 2 6-14 4z" fill="#fff"/><rect x="18" y="20" width="2.5" height="7" fill="#fff"/><rect x="15" y="26" width="9" height="2.5" fill="#fff"/>',
};
export const SAFETY_COLORS = {
  fire_station: "#D32F2F", police_station: "#1A237E", police_post: "#3F6FD8",
  lamp: "#E0A100", speed_camera: "#EF6C00", cctv: "#7B1FA2",
};
const glyphFor = { fire_station: "fire", police_station: "police", police_post: "post", lamp: "lamp", speed_camera: "speed", cctv: "cctv" };
export const SAFETY_SIGNS = Object.fromEntries(
  Object.entries(SAFETY_COLORS).map(([k, c]) => [k, square(c, GLYPHS[glyphFor[k]].replaceAll("currentColor", c))])
);
export const SAFETY_NEW_SIGNS = Object.fromEntries(
  ["lamp", "cctv", "speed_camera"].map((k) => [k, square(SAFETY_COLORS[k], GLYPHS[glyphFor[k]].replaceAll("currentColor", SAFETY_COLORS[k]), { ring: true })])
);

// ---------------------------------------------------------------------------
// Education signs
// ---------------------------------------------------------------------------
const EDU_GLYPHS = {
  school: '<path d="M20 11l11 5-11 5-11-5z" fill="#fff"/><path d="M13 19v5c2 2 4.5 3 7 3s5-1 7-3v-5l-7 3z" fill="#fff"/><rect x="29.5" y="16" width="1.6" height="7" fill="#fff"/>',
  kindergarten: '<rect x="11" y="20" width="8" height="8" fill="#fff"/><rect x="21" y="20" width="8" height="8" fill="#fff"/><rect x="16" y="12" width="8" height="8" fill="#fff"/><text x="20" y="18.6" font-size="6" font-family="Arial" font-weight="700" text-anchor="middle" fill="currentColor">A</text>',
};
export const EDU_COLORS = { school: "#00838F", kindergarten_state: "#F57C00", kindergarten_private: "#C2185B" };
export const EDU_SIGNS = {
  school: square(EDU_COLORS.school, EDU_GLYPHS.school),
  kindergarten_state: square(EDU_COLORS.kindergarten_state, EDU_GLYPHS.kindergarten.replace("currentColor", EDU_COLORS.kindergarten_state)),
  kindergarten_private: square(EDU_COLORS.kindergarten_private, EDU_GLYPHS.kindergarten.replace("currentColor", EDU_COLORS.kindergarten_private)),
};
export const EDU_NEW_SIGNS = {
  school: square(EDU_COLORS.school, EDU_GLYPHS.school, { ring: true }),
  kindergarten: square(EDU_COLORS.kindergarten_state, EDU_GLYPHS.kindergarten.replace("currentColor", EDU_COLORS.kindergarten_state), { ring: true }),
};
