// Small dependency-free bar chart (pastel palette) for a year → value series.
export default function BarChart({ data, color = "#00838F", format = (v) => v.toLocaleString("en-US"), height = 140 }) {
  const max = Math.max(1, ...data.map((d) => d.value));
  return (
    <div className="bar-chart" style={{ "--h": `${height}px` }}>
      {data.map((d) => (
        <div key={d.label} className="bar-col" title={`${d.label}: ${format(d.value)}`}>
          <div className="bar-val">{format(d.value)}</div>
          <div className="bar" style={{ height: `${(d.value / max) * 100}%`, background: color }} />
          <div className="bar-label">{d.label}</div>
        </div>
      ))}
    </div>
  );
}
