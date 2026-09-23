import { useEffect, useState } from "react";
import { useProgress } from "../hooks/useProgress";

// Pastel preloader: a bar filling left → right with the percentage beside it.
export function ProgressBar({ pct, label }) {
  return (
    <div className="progress" role="progressbar" aria-valuemin={0} aria-valuemax={100} aria-valuenow={pct} aria-label={label}>
      <div className="progress-track">
        <div className="progress-fill" style={{ width: `${pct}%` }} />
      </div>
      <div className="progress-meta">
        <span>{label}</span>
        <strong>{pct}%</strong>
      </div>
    </div>
  );
}

// Covers its (position: relative) parent while something inside it loads,
// then fades out once it reaches 100%.
export function LoadingOverlay({ done, floor = 0, label = "Loading", className = "" }) {
  const pct = useProgress(done, floor);
  const [gone, setGone] = useState(false);
  useEffect(() => {
    if (!done) return setGone(false);
    const t = setTimeout(() => setGone(true), 450);
    return () => clearTimeout(t);
  }, [done]);
  if (gone) return null;
  return (
    <div className={`loading-overlay ${done ? "is-done" : ""} ${className}`}>
      <ProgressBar pct={pct} label={label} />
    </div>
  );
}
