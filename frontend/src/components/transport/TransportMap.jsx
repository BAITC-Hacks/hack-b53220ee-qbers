import { forwardRef, useEffect, useImperativeHandle, useRef, useState } from "react";
import { ASTANA } from "../../lib/areas";
import { env } from "../../lib/env";
import { boundsOf, districtIndexAt, polygonsOf } from "../../lib/geo";
import { loadScript } from "../../lib/loadScript";
import { SIGNS } from "../../lib/signs";
import { LoadingOverlay } from "../ProgressBar";

const MAPGL_URL = "https://mapgl.2gis.com/api/js/v1";
const PADDING = { top: 60, right: 40, bottom: 40, left: 40 };
// Below this zoom bus stops are small dots (markers always draw above lines, so full
// signs at city scale would hide the bus routes); above it they become bus-stop signs.
const SIGN_ZOOM = 12;
const BUS_DOT = { icon: SIGNS.busDot, size: [9, 9], anchor: [4.5, 4.5] };
const BUS_SIGN = { icon: SIGNS.bus, size: [20, 20], anchor: [10, 10] };
const esc = (s) => String(s).replace(/[&<>"']/g, (c) => `&#${c.charCodeAt(0)};`);

/**
 * 2GIS map for the transport tab: districts, routes, existing stops/stations and the
 * user's new ones. Drop a sign from the sidebar onto the map to place a new stop.
 */
const TransportMap = forwardRef(function TransportMap(
  { data, newStops, showRegions, showRoutes, showStops, selected, onDrop },
  ref
) {
  const el = useRef(null);
  const map = useRef(null);
  const layers = useRef({ regions: [], routes: [], news: [], popup: null });
  const openedAt = useRef(0); // a sign's click also reaches the map — don't close the popup it just opened
  const busMarkers = useRef([]);
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

  function popup(coordinates, html) {
    openedAt.current = Date.now();
    layers.current.popup?.destroy();
    layers.current.popup = new window.mapgl.HtmlMarker(map.current, {
      coordinates,
      html: `<div class="map-popup">${html}</div>`,
      anchor: [0, 0],
      zIndex: 1000,
    });
  }

  // ---- create the map + static layers (stops, stations) once ----
  useEffect(() => {
    if (!env.dgisKey) {
      setError("VITE_DGIS_API_KEY is not set in .env");
      return undefined;
    }
    let cancelled = false;
    const markers = [];
    const fallback = setTimeout(() => !cancelled && setStage({ floor: 100, done: true }), 15000);

    loadScript(MAPGL_URL)
      .then(async () => {
        if (cancelled) return;
        setStage({ floor: 30, done: false });
        const m = new window.mapgl.Map(el.current, { center: ASTANA, zoom: 10.6, key: env.dgisKey, lang: "en", zoomControl: "topRight" });
        map.current = m;
        m.on("click", () => {
          if (Date.now() - openedAt.current < 250) return;
          layers.current.popup?.destroy();
          layers.current.popup = null;
        });
        setStage({ floor: 45, done: false });

        // Existing bus stops — added in batches so the preloader keeps moving.
        const stops = data.bus_stops;
        let signs = m.getZoom() >= SIGN_ZOOM;
        m.on("zoomend", () => {
          const want = m.getZoom() >= SIGN_ZOOM;
          if (want === signs) return;
          signs = want;
          busMarkers.current.forEach((mk) => mk.setIcon(want ? BUS_SIGN : BUS_DOT));
        });
        for (let i = 0; i < stops.length; i++) {
          const [lon, lat, d, name, routes] = stops[i];
          const mk = new window.mapgl.Marker(m, { coordinates: [lon, lat], ...(signs ? BUS_SIGN : BUS_DOT), zIndex: 10 });
          busMarkers.current.push(mk);
          mk.on("click", () =>
            popup([lon, lat], `<strong>${esc(name)}</strong><span>Bus stop · ${esc(data.districts[d].name)}</span>${
              routes.length ? `<span>Routes ${esc(routes.join(", "))} (Zenodo data)</span>` : ""
            }`)
          );
          markers.push(mk);
          if (i % 150 === 149) {
            setStage({ floor: 45 + Math.round((i / stops.length) * 35), done: false });
            await new Promise((r) => setTimeout(r, 0));
            if (cancelled) return;
          }
        }
        for (const s of data.rail_stations) {
          const mk = new window.mapgl.Marker(m, {
            coordinates: [s.lon, s.lat], icon: s.kind === "lrt" ? SIGNS.lrt : SIGNS.rail, size: [28, 28], anchor: [14, 14], zIndex: 20,
          });
          mk.on("click", () =>
            popup([s.lon, s.lat], `<strong>${esc(s.name)}</strong><span>${s.kind === "lrt" ? "LRT station" : "Railway station"}${
              s.district != null ? ` · ${esc(data.districts[s.district].name)}` : ""
            }</span>`)
          );
          markers.push(mk);
        }
        setStage({ floor: 85, done: false });
        setReady(true);
        m.once("idle", () => !cancelled && setStage({ floor: 100, done: true }));
      })
      .catch((e) => !cancelled && setError(`${e.message} — check your internet connection.`));

    return () => {
      cancelled = true;
      clearTimeout(fallback);
      markers.forEach((mk) => mk.destroy());
      busMarkers.current = [];
      Object.values(layers.current).flat().forEach((l) => l?.destroy?.());
      layers.current = { regions: [], routes: [], news: [], popup: null };
      map.current?.destroy();
      map.current = null;
    };
  }, [data]);

  // ---- bus stop toggle ----
  useEffect(() => {
    if (!ready) return;
    busMarkers.current.forEach((mk) => (showStops ? mk.show() : mk.hide()));
  }, [ready, showStops]);

  // ---- district polygons (toggle + highlight the selected one) ----
  useEffect(() => {
    if (!ready) return;
    layers.current.regions.forEach((p) => p.destroy());
    layers.current.regions = [];
    if (!showRegions) return;
    data.districts.forEach((d, i) => {
      const active = selected == null || selected === i;
      for (const rings of polygonsOf(d)) {
        const poly = new window.mapgl.Polygon(map.current, {
          coordinates: rings,
          color: `${d.color}${active ? "55" : "22"}`,
          strokeColor: d.color,
          strokeWidth: selected === i ? 4 : 2,
          zIndex: 1,
        });
        poly.on("click", (e) =>
          popup(e.lngLat, `<strong>${esc(d.name)} district</strong><span>${d.population.toLocaleString("en-US")} residents</span>`)
        );
        layers.current.regions.push(poly);
      }
    });
  }, [ready, showRegions, selected, data]);

  // ---- Zenodo bus routes ----
  // 2GIS only draws one of several polylines created in the same instant, so they are
  // added a few frames apart.
  useEffect(() => {
    if (!ready) return undefined;
    let cancelled = false;
    layers.current.routes.forEach((p) => p.destroy());
    layers.current.routes = [];
    if (!showRoutes) return undefined;
    (async () => {
      for (const r of data.routes) {
        const line = r.shape["1"] || Object.values(r.shape)[0];
        if (!line) continue;
        await new Promise((res) => setTimeout(res, 60));
        if (cancelled) return;
        layers.current.routes.push(new window.mapgl.Polyline(map.current, { coordinates: line, width: 5, color: r.color, zIndex: 5 }));
      }
    })();
    return () => {
      cancelled = true;
    };
  }, [ready, showRoutes, data]);

  // ---- the user's new stops/stations ----
  useEffect(() => {
    if (!ready) return;
    layers.current.news.forEach((mk) => mk.destroy());
    layers.current.news = newStops.map((s, i) => {
      const mk = new window.mapgl.Marker(map.current, {
        coordinates: [s.lon, s.lat], icon: s.kind === "rail" ? SIGNS.newRail : SIGNS.newBus, size: [34, 34], anchor: [17, 17], zIndex: 30,
      });
      mk.on("click", () =>
        popup([s.lon, s.lat], `<strong>New ${s.kind === "rail" ? "train station" : "bus stop"} #${i + 1}</strong><span>Remove it from the list in the sidebar.</span>`)
      );
      return mk;
    });
  }, [ready, newStops]);

  // ---- animated region zoom: pull back to the city, then glide into the region ----
  useEffect(() => {
    if (!ready) return undefined;
    const m = map.current;
    const target = selected == null ? boundsOf(data.districts.map((d) => d.bbox)) : boundsOf([data.districts[selected].bbox]);
    m.setZoom(Math.min(m.getZoom(), 10.2), { duration: 600, easing: "easeInOutQuad" });
    const t = setTimeout(() => m.fitBounds(target, { padding: PADDING, animation: { duration: 1100, easing: "easeInOutCubic" } }), 620);
    return () => clearTimeout(t);
  }, [ready, selected, data]);

  // ---- drag & drop from the sidebar palette ----
  function handleDrop(e) {
    e.preventDefault();
    setDropHint(null);
    const kind = e.dataTransfer.getData("application/x-stop-kind");
    if (!kind || !map.current) return;
    const rect = el.current.getBoundingClientRect();
    const [lon, lat] = map.current.unproject([e.clientX - rect.left, e.clientY - rect.top]);
    if (districtIndexAt(lon, lat, data.districts) < 0) {
      setDropHint("Drop it inside Astana's city limits.");
      setTimeout(() => setDropHint(null), 2500);
      return;
    }
    onDrop(kind, lon, lat);
  }

  return (
    <div
      className="map-frame transport-map"
      onDragOver={(e) => {
        if (e.dataTransfer.types.includes("application/x-stop-kind")) {
          e.preventDefault();
          e.dataTransfer.dropEffect = "copy";
          setDropHint("Release to place it here");
        }
      }}
      onDragLeave={() => setDropHint(null)}
      onDrop={handleDrop}
    >
      <div ref={el} className="map" aria-label="Map of Astana with bus stops, stations and districts" />
      {dropHint && <div className="drop-hint">{dropHint}</div>}
      {error ? (
        <div className="map-error"><i className="fa-solid fa-triangle-exclamation" /> {error}</div>
      ) : (
        <LoadingOverlay done={stage.done} floor={stage.floor} label="Loading transport map" />
      )}
    </div>
  );
});

export default TransportMap;
