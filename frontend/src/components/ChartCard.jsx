import { useEffect, useRef, useState } from "react";
import { api } from "../lib/api";
import { env } from "../lib/env";
import { loadScript } from "../lib/loadScript";

function loadCharts() {
  return loadScript("https://www.gstatic.com/charts/loader.js").then(
    () =>
      new Promise((resolve) => {
        google.charts.load("current", { packages: ["corechart"], mapsApiKey: env.googleApiKey });
        google.charts.setOnLoadCallback(resolve);
      })
  );
}

export default function ChartCard() {
  const el = useRef(null);
  const [error, setError] = useState(null);

  useEffect(() => {
    let chart;
    let data;
    const options = {
      backgroundColor: "transparent",
      seriesType: "bars",
      series: { 1: { type: "line", targetAxisIndex: 1, lineWidth: 3, pointSize: 7 } },
      colors: ["#7c5cff", "#22f0ff"],
      legend: { position: "top", textStyle: { color: "#c9d2f0", fontName: "Rubik" } },
      hAxis: { textStyle: { color: "#7f8bb3", fontName: "Rubik" } },
      vAxes: {
        0: { textStyle: { color: "#7f8bb3" }, gridlines: { color: "#1c2544" }, baselineColor: "#1c2544" },
        1: { textStyle: { color: "#7f8bb3" }, gridlines: { color: "transparent" } },
      },
      chartArea: { left: 48, right: 56, top: 40, bottom: 32 },
      bar: { groupWidth: "55%" },
      animation: { startup: true, duration: 900, easing: "out" },
    };
    const draw = () => chart && chart.draw(data, options);

    Promise.all([loadCharts(), api("stats/")])
      .then(([, stats]) => {
        data = google.visualization.arrayToDataTable([stats.columns, ...stats.rows]);
        chart = new google.visualization.ComboChart(el.current);
        draw();
      })
      .catch((e) => setError(e.message));

    window.addEventListener("resize", draw);
    return () => window.removeEventListener("resize", draw);
  }, []);

  return (
    <section className="card">
      <header className="card-head">
        <i className="fa-solid fa-chart-column" />
        <div>
          <h3>Google Charts</h3>
          <p>Growth metrics from the Postgres <code>Metric</code> table</p>
        </div>
      </header>
      {error ? <p className="card-error"><i className="fa-solid fa-triangle-exclamation" /> {error}</p> : null}
      <div ref={el} className="chart" />
    </section>
  );
}
