import { useEffect, useRef, useState } from "react";
import { api } from "../lib/api";
import { env } from "../lib/env";
import { loadScript } from "../lib/loadScript";

const NIGHT_STYLE = [
  { elementType: "geometry", stylers: [{ color: "#0b1020" }] },
  { elementType: "labels.text.fill", stylers: [{ color: "#7f8bb3" }] },
  { elementType: "labels.text.stroke", stylers: [{ color: "#0b1020" }] },
  { featureType: "road", elementType: "geometry", stylers: [{ color: "#1a2342" }] },
  { featureType: "road.highway", elementType: "geometry", stylers: [{ color: "#27335c" }] },
  { featureType: "water", elementType: "geometry", stylers: [{ color: "#050814" }] },
  { featureType: "poi", stylers: [{ visibility: "off" }] },
  { featureType: "transit", stylers: [{ visibility: "off" }] },
];

// The Maps script finishes loading before the API is ready; wait for its callback.
let mapsReady;
function loadMaps() {
  mapsReady ??= new Promise((resolve, reject) => {
    window.__initGoogleMaps = resolve;
    loadScript(
      `https://maps.googleapis.com/maps/api/js?key=${env.googleApiKey}&loading=async&callback=__initGoogleMaps`
    ).catch(reject);
  }).then(() => google.maps.importLibrary("maps"));
  return mapsReady;
}

export default function MapCard() {
  const el = useRef(null);
  const [error, setError] = useState(null);

  useEffect(() => {
    if (!env.googleApiKey) return setError("VITE_GOOGLE_API_KEY is not set in .env");
    let cancelled = false;
    Promise.all([loadMaps(), api("locations/")])
      .then(([, { locations }]) => {
        if (cancelled) return;
        const map = new google.maps.Map(el.current, {
          center: { lat: 37.6, lng: -122.2 },
          zoom: 9,
          styles: NIGHT_STYLE,
          disableDefaultUI: true,
          zoomControl: true,
        });
        const bounds = new google.maps.LatLngBounds();
        const info = new google.maps.InfoWindow();
        locations.forEach((loc) => {
          const marker = new google.maps.Marker({
            map,
            position: loc,
            title: loc.name,
            icon: {
              path: google.maps.SymbolPath.CIRCLE,
              scale: 9,
              fillColor: "#22f0ff",
              fillOpacity: 0.9,
              strokeColor: "#ffffff",
              strokeWeight: 2,
            },
          });
          marker.addListener("click", () => {
            info.setContent(`<strong style="color:#0b1020">${loc.name}</strong>`);
            info.open({ map, anchor: marker });
          });
          bounds.extend(loc);
        });
        if (locations.length) map.fitBounds(bounds, 48);
      })
      .catch((e) => setError(e.message));
    return () => {
      cancelled = true;
    };
  }, []);

  return (
    <section className="card">
      <header className="card-head">
        <i className="fa-solid fa-map-location-dot" />
        <div>
          <h3>Google Maps</h3>
          <p>Pins served from the Postgres <code>Location</code> table</p>
        </div>
      </header>
      {error ? <p className="card-error"><i className="fa-solid fa-triangle-exclamation" /> {error}</p> : null}
      <div ref={el} className="map" />
    </section>
  );
}
