import { useEffect, useState } from "react";

// Loading percentage for the pastel preloader bars.
// Creeps toward 95% while work is in flight, never below `floor` (set it as real
// milestones complete), and snaps to 100% the moment `done` becomes true.
export function useProgress(done, floor = 0) {
  const [pct, setPct] = useState(0);
  useEffect(() => {
    if (done) {
      setPct(100);
      return undefined;
    }
    setPct((p) => Math.max(p, floor));
    const id = setInterval(() => setPct((p) => Math.max(floor, p + (95 - p) * 0.05)), 100);
    return () => clearInterval(id);
  }, [done, floor]);
  return Math.min(100, Math.round(pct));
}
