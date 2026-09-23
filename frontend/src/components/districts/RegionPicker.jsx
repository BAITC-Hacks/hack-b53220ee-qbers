// "All of Astana" + ◀ district ▶ — cycling animates the map to the next district.
export default function RegionPicker({ districts, selected, onChange }) {
  const n = districts.length;
  return (
    <div className="region-picker">
      <button aria-label="Previous district" onClick={() => onChange(selected == null ? n - 1 : selected === 0 ? null : selected - 1)}>
        <i className="fa-solid fa-chevron-left" />
      </button>
      <select aria-label="Zoom to district" value={selected ?? ""} onChange={(e) => onChange(e.target.value === "" ? null : Number(e.target.value))}>
        <option value="">All of Astana</option>
        {districts.map((d, i) => <option key={d.name} value={i}>{d.name} district</option>)}
      </select>
      <button aria-label="Next district" onClick={() => onChange(selected == null ? 0 : selected === n - 1 ? null : selected + 1)}>
        <i className="fa-solid fa-chevron-right" />
      </button>
    </div>
  );
}
