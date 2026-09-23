// The five budget areas, in tab order. Keys match core/budget.py AREAS on the backend.
export const AREAS = [
  { id: "transport", label: "Transport", icon: "fa-solid fa-bus", tint: "#C9F3F4", ink: "#005F62",
    blurb: "Roads, public transit, cycling lanes and parking." },
  { id: "greenery", label: "Greenery", icon: "fa-solid fa-tree", tint: "#DDF4D4", ink: "#2C5F27",
    blurb: "Parks, tree planting, irrigation and green corridors." },
  { id: "social", label: "Social services", icon: "fa-solid fa-hands-holding-child", tint: "#FFF3B5", ink: "#6B5200",
    blurb: "Schools, clinics, community centres and social support." },
  { id: "safety", label: "Safety", icon: "fa-solid fa-shield-halved", tint: "#FFDDD0", ink: "#83361B",
    blurb: "Street lighting, emergency services and CCTV." },
  { id: "city", label: "City services", icon: "fa-solid fa-city", tint: "#E2E5FB", ink: "#353B8C",
    blurb: "Utilities, waste collection, snow removal and maintenance." },
];

export const AREA_IDS = AREAS.map((a) => a.id);

// Astana (Baiterek tower) — [longitude, latitude] as 2GIS expects.
export const ASTANA = [71.4304, 51.1282];
