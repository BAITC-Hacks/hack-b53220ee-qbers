import { forwardRef, useEffect, useImperativeHandle, useRef, useState } from "react";
import { ASTANA } from "../../lib/areas";
import { env } from "../../lib/env";
import { boundsOf, districtIndexAt, polygonsOf } from "../../lib/geo";
import { cellSquare, needColor } from "../../lib/green";
import { loadScript } from "../../lib/loadScript";
import { LoadingOverlay } from "../ProgressBar";

const MAPGL_URL = "https://mapgl.2gis.com/api/js/v1";
const PADDING = { top: 60, right: 40, bottom: 40, left: 40 };
const dot = (fill, r, stroke = "#fff") =>
  `data:image/svg+xml;charset=utf-8,${encodeURIComponent(
    `<svg xmlns="http://www.w3.org/2000/svg" width="${r * 2 + 2}" height="${r * 2 + 2}"><circle cx="${r + 1}" cy="${r + 1}" r="${r}" fill="${fill}" stroke="${stroke}" stroke-width="1.2"/></svg>`
  )}`;
export const TREE_ICONS = { existing: dot("#1B5E20", 3.5), added: dot("#7CB342", 4.5, "#ffffff") };
const EXISTING = { icon: TREE_ICONS.existing, size: [9, 9], anchor: [4.5, 4.5] };
const ADDED = { icon: TREE_ICONS.added, size: [11, 11], anchor: [5.5, 5.5] };
const NEED_BUCKETS = { r: "#E5393566", a: "#FFB30066", y: "#C0CA3366", g: "#43A04755" };
const bucketOf = (color) => ({ "#E53935": "r", "#FFB300": "a", "#C0CA33": "y", "#43A047": "g" })[color];
const onlySrc = (name) => ["match", ["sourceAttr", "src"], [name], true, false];

/**
 * 2GIS map for the greenery tab, styled after trees.sg: soft green parks, darker woodland,
 * trees as small dots, and home blocks shaded by green m² per resident nearby.
 */
const GreeneryMap = forwardRef(function GreeneryMap(
  { data, analysis, goal, treePoints, showRegions, showGreen, showNeed, showTrees, selected, onDrop },
  ref
) {
  const el = useRef(null);
  const map = useRef(null);
  const needSource = useRef(null);
  const layers = useRef({ regions: [], added: [], existing: [] });
  const [stage, setStage] = useState({ floor: 0, done: false });
  const [ready, setReady] = useState(false);
  const [error, setError] = useState(null);
  const [dropHint, setDropHint] = useState(null);

  useImperativeHandle(ref, () => ({
    flyTo(lon, lat, zoom = 15) {
      map.current?.setCenter([lon, lat], { duration: 900, easing: "easeInOutQuad" });
      map.current?.setZoom(zoom, { duration: 900, easing: "easeInOutQuad" });
    },
  }));

  // ---- map, green-area layers, existing trees ----
  useEffect(() => {
    if (!env.dgisKey) {
      setError("VITE_DGIS_API_KEY is not set in .env");
      return undefined;
    }
    let cancelled = false;
    const fallback = setTimeout(() => !cancelled && setStage({ floor: 100, done: true }), 15000);
    loadScript(MAPGL_URL)
      .then(() => {
        if (cancelled) return;
        setStage({ floor: 30, done: false });
        const m = new window.mapgl.Map(el.current, { center: ASTANA, zoom: 10.6, key: env.dgisKey, lang: "en", zoomControl: "topRight" });
        map.current = m;
        new window.mapgl.GeoJsonSource(m, {
          data: {
            type: "FeatureCollection",
            features: data.green_areas.map(([category, rings]) => ({
              type: "Feature", properties: { layer: category }, geometry: { type: "Polygon", coordinates: rings },
            })),
          },
          attributes: { src: "green" },
        });
        needSource.current = new window.mapgl.GeoJsonSource(m, {
          data: { type: "FeatureCollection", features: [] },
          attributes: { src: "need" },
        });
        m.once("styleload", async () => {
          if (cancelled) return;
          setStage({ floor: 50, done: false });
          setReady(true);
          // Existing mapped trees, in batches so the preloader keeps moving.
          for (let i = 0; i < data.trees.length; i++) {
            const [lon, lat] = data.trees[i];
            layers.current.existing.push(new window.mapgl.Marker(m, { coordinates: [lon, lat], ...EXISTING, zIndex: 10 }));
            if (i % 300 === 299) {
              setStage({ floor: 50 + Math.round((i / data.trees.length) * 40), done: false });
              await new Promise((r) => setTimeout(r, 0));
              if (cancelled) return;
            }
          }
          setStage({ floor: 92, done: false });
          m.once("idle", () => !cancelled && setStage({ floor: 100, done: true }));
        });
      })
      .catch((e) => !cancelled && setError(`${e.message} — check your internet connection.`));
    return () => {
      cancelled = true;
      clearTimeout(fallback);
      Object.values(layers.current).flat().forEach((l) => l?.destroy?.());
      layers.current = { regions: [], added: [], existing: [] };
      map.current?.destroy();
      map.current = null;
    };
  }, [data]);

  // ---- layer toggles (style layers are added/removed) ----
  useEffect(() => {
    if (!ready) return;
    const m = map.current;
    const setLayer = (id, on, def) => {
      try { m.removeLayer(id); } catch { /* not added yet */ }
      if (on) m.addLayer(def);
    };
    setLayer("need-cells", showNeed, {
      id: "need-cells", type: "polygon", filter: onlySrc("need"),
      style: { color: ["match", ["get", "b"], ["r"], NEED_BUCKETS.r, ["a"], NEED_BUCKETS.a, ["y"], NEED_BUCKETS.y, NEED_BUCKETS.g] },
    });
    setLayer("green-forest", showGreen, {
      id: "green-forest", type: "polygon", filter: ["all", onlySrc("green"), ["match", ["get", "layer"], ["forest"], true, false]],
      style: { color: "#2E7D3280" },
    });
    setLayer("green-park", showGreen, {
      id: "green-park", type: "polygon", filter: ["all", onlySrc("green"), ["match", ["get", "layer"], ["park"], true, false]],
      style: { color: "#66BB6AA6" },
    });
  }, [ready, showGreen, showNeed]);

  // ---- need shading follows the live analysis ----
  useEffect(() => {
    if (!ready || !needSource.current || !analysis) return;
    needSource.current.setData({
      type: "FeatureCollection",
      features: analysis.cells
        .filter((c) => c.pop >= 5)
        .map((c) => ({ type: "Feature", properties: { b: bucketOf(needColor(c.after, goal)) }, geometry: { type: "Polygon", coordinates: cellSquare(c.lon, c.lat) } })),
    });
  }, [ready, analysis, goal]);

  // ---- tree visibility ----
  useEffect(() => {
    if (!ready) return;
    [...layers.current.existing, ...layers.current.added].forEach((mk) => (showTrees ? mk.show() : mk.hide()));
  }, [ready, showTrees, treePoints]);

  // ---- new trees ----
  useEffect(() => {
    if (!ready) return undefined;
    let cancelled = false;
    layers.current.added.forEach((mk) => mk.destroy());
    layers.current.added = [];
    (async () => {
      for (let i = 0; i < treePoints.length; i++) {
        const [lon, lat] = treePoints[i];
        const mk = new window.mapgl.Marker(map.current, { coordinates: [lon, lat], ...ADDED, zIndex: 20 });
        if (!showTrees) mk.hide();
        layers.current.added.push(mk);
        if (i % 400 === 399) {
          await new Promise((r) => setTimeout(r, 0));
          if (cancelled) return;
        }
      }
    })();
    return () => {
      cancelled = true;
    };
  }, [ready, treePoints]); // eslint-disable-line react-hooks/exhaustive-deps

  // ---- district outlines ----
  useEffect(() => {
    if (!ready) return;
    layers.current.regions.forEach((p) => p.destroy());
    layers.current.regions = [];
    if (!showRegions) return;
    data.districts.forEach((d, i) => {
      for (const rings of polygonsOf(d)) {
        layers.current.regions.push(new window.mapgl.Polygon(map.current, {
          coordinates: rings,
          color: selected === i ? `${d.color}22` : "#00000000",
          strokeColor: d.color,
          strokeWidth: selected === i ? 4 : 2,
          zIndex: 1,
        }));
      }
    });
  }, [ready, showRegions, selected, data]);

  // ---- animated zoom to the chosen district ----
  useEffect(() => {
    if (!ready) return undefined;
    const m = map.current;
    const target = selected == null ? boundsOf(data.districts.map((d) => d.bbox)) : boundsOf([data.districts[selected].bbox]);
    m.setZoom(Math.min(m.getZoom(), 10.2), { duration: 600, easing: "easeInOutQuad" });
    const t = setTimeout(() => m.fitBounds(target, { padding: PADDING, animation: { duration: 1100, easing: "easeInOutCubic" } }), 620);
    return () => clearTimeout(t);
  }, [ready, selected, data]);

  function handleDrop(e) {
    e.preventDefault();
    setDropHint(null);
    if (!e.dataTransfer.getData("application/x-tree") || !map.current) return;
    const rect = el.current.getBoundingClientRect();
    const [lon, lat] = map.current.unproject([e.clientX - rect.left, e.clientY - rect.top]);
    if (districtIndexAt(lon, lat, data.districts) < 0) {
      setDropHint("Drop trees inside Astana's city limits.");
      setTimeout(() => setDropHint(null), 2500);
      return;
    }
    onDrop(lon, lat);
  }

  return (
    <div
      className="map-frame transport-map"
      onDragOver={(e) => {
        if (e.dataTransfer.types.includes("application/x-tree")) {
          e.preventDefault();
          e.dataTransfer.dropEffect = "copy";
          setDropHint("Release to plant here");
        }
      }}
      onDragLeave={() => setDropHint(null)}
      onDrop={handleDrop}
    >
      <div ref={el} className="map" aria-label="Map of Astana's green space and trees" />
      {dropHint && <div className="drop-hint">{dropHint}</div>}
      {error ? (
        <div className="map-error"><i className="fa-solid fa-triangle-exclamation" /> {error}</div>
      ) : (
        <LoadingOverlay done={stage.done} floor={stage.floor} label="Loading green map" />
      )}
    </div>
  );
});

export default GreeneryMap;
