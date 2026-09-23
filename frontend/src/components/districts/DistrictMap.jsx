import { useEffect, useRef, useState } from "react";
import { ASTANA } from "../../lib/areas";
import { env } from "../../lib/env";
import { districtIndexAt } from "../../lib/geo";
import { loadScript } from "../../lib/loadScript";
import { useMapDrop } from "../dnd/DndProvider";
import { LoadingOverlay } from "../ProgressBar";
import { useDistrictLayer, useRegionZoom } from "./districtLayers";

const MAPGL_URL = "https://mapgl.2gis.com/api/js/v1";

/**
 * A 2GIS map of Astana with coloured, selectable districts and animated district zoom.
 * Tab-specific layers go in `children(map, ready)` — components that add markers etc.
 * Pass `drop={{ id, accept, onDrop(item, lon, lat) }}` to accept palette items.
 */
export default function DistrictMap({ districts, selected, showRegions = true, fill = true, onSelect, drop, label = "Loading map", children }) {
  const el = useRef(null);
  const map = useRef(null);
  const [ready, setReady] = useState(false);
  const [stage, setStage] = useState({ floor: 0, done: false });
  const [error, setError] = useState(null);
  const [hint, setHint] = useState(null);

  const target = useMapDrop(drop?.id || "district-map", {
    accept: (kind) => Boolean(drop?.accept?.(kind)),
    onDrop: (item, x, y) => {
      if (!map.current) return;
      const rect = el.current.getBoundingClientRect();
      const [lon, lat] = map.current.unproject([x - rect.left, y - rect.top]);
      if (districtIndexAt(lon, lat, districts) < 0) {
        setHint("Drop it inside Astana's city limits.");
        setTimeout(() => setHint(null), 2500);
        return;
      }
      drop.onDrop(item, lon, lat);
    },
  });

  useEffect(() => {
    if (!env.dgisKey) {
      setError("VITE_DGIS_API_KEY is not set in .env");
      return undefined;
    }
    let cancelled = false;
    const fallback = setTimeout(() => !cancelled && setStage({ floor: 100, done: true }), 12000);
    loadScript(MAPGL_URL)
      .then(() => {
        if (cancelled) return;
        setStage({ floor: 40, done: false });
        const m = new window.mapgl.Map(el.current, { center: ASTANA, zoom: 10.6, key: env.dgisKey, lang: "en", zoomControl: "topRight" });
        map.current = m;
        setStage({ floor: 60, done: false });
        m.once("styleload", () => {
          if (cancelled) return;
          setReady(true);
          setStage({ floor: 85, done: false });
        });
        m.once("idle", () => !cancelled && setStage({ floor: 100, done: true }));
      })
      .catch((e) => !cancelled && setError(`${e.message} — check your internet connection.`));
    return () => {
      cancelled = true;
      clearTimeout(fallback);
      setReady(false);
      map.current?.destroy();
      map.current = null;
    };
  }, []);

  useDistrictLayer(map, ready, districts, { show: showRegions, selected, fill, onClick: (i) => onSelect?.(i) });
  useRegionZoom(map, ready, districts, selected);

  return (
    <div ref={target.setNodeRef} className={`map-frame transport-map ${target.accepting ? "is-drop-target" : ""} ${target.isOver ? "is-over" : ""}`}>
      <div ref={el} className="map" aria-label="Map of Astana's districts" />
      {ready && children?.(map.current, ready)}
      {(hint || target.isOver) && <div className="drop-hint">{hint || "Release to place it here"}</div>}
      {error ? (
        <div className="map-error"><i className="fa-solid fa-triangle-exclamation" /> {error}</div>
      ) : (
        <LoadingOverlay done={stage.done} floor={stage.floor} label={label} />
      )}
    </div>
  );
}
