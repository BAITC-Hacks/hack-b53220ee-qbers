// Shared district behaviour for every map tab: coloured district polygons, the selected
// district highlighted, and an animated zoom (pull back to the city, glide into the district).
import { useEffect, useRef } from "react";
import { boundsOf, polygonsOf } from "../../lib/geo";

const PADDING = { top: 60, right: 40, bottom: 40, left: 40 };

export function useDistrictLayer(mapRef, ready, districts, { show = true, selected = null, fill = true, onClick } = {}) {
  const polys = useRef([]);
  const clickRef = useRef(onClick);
  clickRef.current = onClick;
  useEffect(() => {
    if (!ready || !mapRef.current) return undefined;
    polys.current.forEach((p) => p.destroy());
    polys.current = [];
    if (!show) return undefined;
    districts.forEach((d, i) => {
      const active = selected == null || selected === i;
      for (const rings of polygonsOf(d)) {
        const poly = new window.mapgl.Polygon(mapRef.current, {
          coordinates: rings,
          color: fill ? `${d.color}${active ? (selected === i ? "55" : "3a") : "18"}` : selected === i ? `${d.color}22` : "#00000000",
          strokeColor: d.color,
          strokeWidth: selected === i ? 4 : 2,
          zIndex: 1,
        });
        poly.on("click", (e) => clickRef.current?.(i, e));
        polys.current.push(poly);
      }
    });
    return () => {
      polys.current.forEach((p) => p.destroy());
      polys.current = [];
    };
  }, [ready, districts, show, selected, fill, mapRef]);
}

export function useRegionZoom(mapRef, ready, districts, selected) {
  useEffect(() => {
    if (!ready || !mapRef.current) return undefined;
    const m = mapRef.current;
    const target = selected == null ? boundsOf(districts.map((d) => d.bbox)) : boundsOf([districts[selected].bbox]);
    m.setZoom(Math.min(m.getZoom(), 10.2), { duration: 600, easing: "easeInOutQuad" });
    const t = setTimeout(() => m.fitBounds(target, { padding: PADDING, animation: { duration: 1100, easing: "easeInOutCubic" } }), 620);
    return () => clearTimeout(t);
  }, [ready, districts, selected, mapRef]);
}
