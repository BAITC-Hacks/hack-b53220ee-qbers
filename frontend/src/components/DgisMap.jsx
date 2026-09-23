import { useEffect, useRef, useState } from "react";
import { ASTANA } from "../lib/areas";
import { env } from "../lib/env";
import { loadScript } from "../lib/loadScript";
import { LoadingOverlay } from "./ProgressBar";

const MAPGL_URL = "https://mapgl.2gis.com/api/js/v1";

// A 2GIS map of Astana. A fresh map is created every time the tab opens,
// with a preloader that follows the real milestones:
// script loaded (40%) → map created (60%) → style loaded (85%) → tiles rendered (100%).
export default function DgisMap({ label }) {
  const el = useRef(null);
  const [stage, setStage] = useState({ floor: 0, done: false });
  const [error, setError] = useState(null);

  useEffect(() => {
    if (!env.dgisKey) {
      setError("VITE_DGIS_API_KEY is not set in .env");
      return undefined;
    }
    let map;
    let cancelled = false;
    const finish = () => !cancelled && setStage({ floor: 100, done: true });
    // Never leave the loader hanging if the 'idle' event is slow on a busy network.
    const fallback = setTimeout(finish, 12000);

    loadScript(MAPGL_URL)
      .then(() => {
        if (cancelled) return;
        setStage({ floor: 40, done: false });
        map = new window.mapgl.Map(el.current, {
          center: ASTANA,
          zoom: 11.5,
          key: env.dgisKey,
          lang: "en",
          zoomControl: "topRight",
        });
        setStage({ floor: 60, done: false });
        map.once("styleload", () => !cancelled && setStage({ floor: 85, done: false }));
        map.once("idle", finish);
        new window.mapgl.Marker(map, { coordinates: ASTANA, label: { text: `Astana · ${label}`, offset: [0, -60] } });
      })
      .catch((e) => {
        if (!cancelled) setError(`${e.message} — check your internet connection.`);
      });

    return () => {
      cancelled = true;
      clearTimeout(fallback);
      map?.destroy();
    };
  }, [label]);

  return (
    <div className="map-frame">
      <div ref={el} className="map" aria-label={`Map of Astana — ${label}`} />
      {error ? (
        <div className="map-error">
          <i className="fa-solid fa-triangle-exclamation" /> {error}
        </div>
      ) : (
        <LoadingOverlay done={stage.done} floor={stage.floor} label="Loading map of Astana" />
      )}
    </div>
  );
}
