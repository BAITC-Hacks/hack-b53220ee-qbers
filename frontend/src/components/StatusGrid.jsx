import { useEffect, useState } from "react";
import { api } from "../lib/api";
import { env } from "../lib/env";

function Tile({ icon, label, value, ok }) {
  return (
    <div className={`tile ${ok ? "ok" : ok === false ? "bad" : ""}`}>
      <i className={icon} />
      <div>
        <span className="tile-label">{label}</span>
        <span className="tile-value">{value}</span>
      </div>
      <i className={`tile-dot fa-solid ${ok ? "fa-circle-check" : ok === false ? "fa-circle-xmark" : "fa-spinner fa-spin"}`} />
    </div>
  );
}

export default function StatusGrid() {
  const [health, setHealth] = useState(null);
  const [error, setError] = useState(null);

  useEffect(() => {
    api("health/").then(setHealth).catch((e) => setError(e.message));
  }, []);

  const djangoOk = health ? true : error ? false : undefined;
  return (
    <div className="status-grid">
      <Tile icon="fa-brands fa-react" label="React" value="Rendering" ok />
      <Tile icon="fa-brands fa-python" label="Django" value={health ? `v${health.django}` : error || "Connecting…"} ok={djangoOk} />
      <Tile
        icon="fa-solid fa-database"
        label="PostgreSQL"
        value={health ? health.database.version : "Waiting on API…"}
        ok={health ? health.database.ok : djangoOk}
      />
      <Tile
        icon="fa-brands fa-google"
        label="Google keys"
        value={env.googleApiKey && env.googleClientId ? "Loaded from .env" : "Missing in .env"}
        ok={Boolean(env.googleApiKey && env.googleClientId)}
      />
    </div>
  );
}
