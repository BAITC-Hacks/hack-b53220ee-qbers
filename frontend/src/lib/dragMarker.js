// A 2GIS HtmlMarker that the user can drag to a new position. The map stops panning
// while a marker is being dragged; `onMoveEnd([lon, lat])` fires when it's released.
export function createDraggableMarker(map, { coordinates, icon, size = 34, title = "", zIndex = 30, onMoveEnd, onClick }) {
  const html = `<div class="drag-marker" title="${title.replace(/"/g, "&quot;")}" style="width:${size}px;height:${size}px">
    <img src="${icon}" alt="" width="${size}" height="${size}" draggable="false" /></div>`;
  const marker = new window.mapgl.HtmlMarker(map, { coordinates, html, anchor: [size / 2, size / 2], zIndex, interactive: true });
  const el = marker.getContent();
  let dragging = null;

  const toLngLat = (e) => {
    const rect = map.getContainer().getBoundingClientRect();
    return map.unproject([e.clientX - rect.left, e.clientY - rect.top]);
  };
  const move = (e) => {
    if (!dragging) return;
    if (Math.hypot(e.clientX - dragging.x, e.clientY - dragging.y) > 3) dragging.moved = true;
    if (dragging.moved) marker.setCoordinates(toLngLat(e));
  };
  const up = (e) => {
    if (!dragging) return;
    const { moved } = dragging;
    dragging = null;
    el.classList.remove("is-dragging");
    window.removeEventListener("pointermove", move);
    window.removeEventListener("pointerup", up);
    if (moved) onMoveEnd?.(toLngLat(e));
    else onClick?.();
  };
  el.addEventListener("pointerdown", (e) => {
    e.stopPropagation(); // keep the map from panning
    e.preventDefault();
    dragging = { x: e.clientX, y: e.clientY, moved: false };
    el.classList.add("is-dragging");
    window.addEventListener("pointermove", move);
    window.addEventListener("pointerup", up);
  });
  // Stop the map's own mouse handlers from seeing the gesture too.
  ["mousedown", "touchstart", "wheel"].forEach((t) => el.addEventListener(t, (e) => e.stopPropagation(), { passive: t !== "mousedown" }));
  return marker;
}
