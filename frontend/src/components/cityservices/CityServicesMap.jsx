import { useEffect } from "react";
import { complaintWeightedPoints, splitByPopulation } from "../../lib/cityHeat";
import { createDraggableMarker } from "../../lib/dragMarker";
import { districtIndexAt } from "../../lib/geo";
import { UTIL_NEW_SIGNS } from "../../lib/signs";
import { useMapDrop } from "../dnd/DndProvider";
import DistrictMap from "../districts/DistrictMap";

/** Heatmap layer (no district fill — borders only) + draggable fix markers. */
function HeatLayer({ map, data, utility }) {
  useEffect(() => {
    if (!map || !data) return undefined;
    const cityTotal = Object.values(data.series[utility] || {}).reduce((a, y) => a + y.count, 0);
    const totals = splitByPopulation(cityTotal, data.districts);
    const points = complaintWeightedPoints(data.cells, data.districts, totals, cityTotal);
    const maxWeight = Math.max(1e-9, ...points.map((p) => p.weight));
    const source = new window.mapgl.GeoJsonSource(map, {
      data: { type: "FeatureCollection", features: points.map((p) => ({ type: "Feature", properties: { weight: p.weight / maxWeight }, geometry: { type: "Point", coordinates: [p.lon, p.lat] } })) },
      attributes: { src: "heat" },
    });
    let layerAdded = false;
    const add = () => {
      try {
        map.addLayer({ id: "utility-heat", type: "heatmap", filter: ["match", ["sourceAttr", "src"], ["heat"], true, false],
          style: { radius: 14, weight: ["get", "weight"], intensity: 0.45 } });
        layerAdded = true;
      } catch { /* style not ready yet */ }
    };
    add();
    if (!layerAdded) map.once("styleload", add);
    return () => {
      try { map.removeLayer("utility-heat"); } catch { /* already gone */ }
      source.destroy();
    };
  }, [map, data, utility]);
  return null;
}

function FixMarkers({ map, fixes, dispatch }) {
  useEffect(() => {
    if (!map) return undefined;
    const markers = fixes.map((f, i) =>
      createDraggableMarker(map, {
        coordinates: [f.lon, f.lat], icon: UTIL_NEW_SIGNS[f.kind], size: 30, zIndex: 40,
        title: `${f.kind.replace("_", " ")} fix — drag to move`,
        onMoveEnd: ([lon, lat]) => dispatch({ type: "move", index: i, lon, lat }),
      })
    );
    return () => markers.forEach((m) => m.destroy());
  }, [map, fixes, dispatch]);
  return null;
}

export default function CityServicesMap({ data, utility, selected, onSelect, fixes, dispatch }) {
  return (
    <DistrictMap
      districts={data.districts}
      selected={selected}
      showRegions
      fill={false}
      onSelect={onSelect}
      label="Loading city services map"
      drop={{
        id: "cityservices-map", accept: (kind) => ["water_pipe", "electrical_wiring", "heater"].includes(kind),
        onDrop: (item, lon, lat) => {
          if (districtIndexAt(lon, lat, data.districts) < 0) return;
          dispatch({ type: "place", kind: item.kind, lon, lat });
        },
      }}
    >
      {(map) => (
        <>
          <HeatLayer map={map} data={data} utility={utility} />
          <FixMarkers map={map} fixes={fixes} dispatch={dispatch} />
        </>
      )}
    </DistrictMap>
  );
}
