// Drag & drop for the map tabs, built on @dnd-kit (MIT): pointer events rather than
// HTML5 drag-and-drop, so it works with mouse, touch, pen and keyboard, and over the
// 2GIS WebGL canvas. Palette items are draggable; each map registers itself as a drop
// target and receives the drop point in screen coordinates.
import { DndContext, DragOverlay, KeyboardSensor, PointerSensor, TouchSensor, useDraggable, useDroppable, useSensor, useSensors } from "@dnd-kit/core";
import { useRef, useState } from "react";

export function DndProvider({ children }) {
  const [active, setActive] = useState(null);
  const sensors = useSensors(
    useSensor(PointerSensor, { activationConstraint: { distance: 4 } }),
    useSensor(TouchSensor, { activationConstraint: { delay: 120, tolerance: 6 } }),
    useSensor(KeyboardSensor)
  );

  function onDragEnd(event) {
    setActive(null);
    const { over, active: item, activatorEvent, delta } = event;
    if (!over?.data.current?.onDrop) return;
    // Final pointer position = where the drag started + how far it moved.
    const start = activatorEvent?.touches?.[0] ?? activatorEvent;
    let x = (start?.clientX ?? 0) + delta.x;
    let y = (start?.clientY ?? 0) + delta.y;
    if (!start?.clientX) {
      // Keyboard drag: drop at the centre of the target.
      const r = over.rect;
      x = r.left + r.width / 2;
      y = r.top + r.height / 2;
    }
    over.data.current.onDrop(item.data.current, x, y);
  }

  return (
    <DndContext sensors={sensors} onDragStart={(e) => setActive(e.active.data.current)} onDragEnd={onDragEnd} onDragCancel={() => setActive(null)}>
      {children}
      <DragOverlay dropAnimation={null}>
        {active ? (
          <div className="drag-ghost">
            <img src={active.icon} alt="" width="40" height="40" />
            <span>{active.label}</span>
          </div>
        ) : null}
      </DragOverlay>
    </DndContext>
  );
}

/** A sign in a sidebar palette that can be dragged onto a map. */
export function PaletteItem({ id, kind, label, icon, hint }) {
  const { attributes, listeners, setNodeRef, isDragging } = useDraggable({ id, data: { kind, label, icon } });
  return (
    <button
      ref={setNodeRef}
      type="button"
      className={`palette-sign ${isDragging ? "is-dragging" : ""}`}
      title={hint || `Drag onto the map to add a ${label.toLowerCase()}`}
      {...listeners}
      {...attributes}
    >
      <img src={icon} alt="" width="36" height="36" />
      <span>{label}</span>
      <i className="fa-solid fa-grip-vertical" />
    </button>
  );
}

/**
 * Make an element (the map frame) a drop target. `accept(kind)` filters what can land here;
 * `onDrop(item, clientX, clientY)` is called with the drop point.
 */
export function useMapDrop(id, { accept, onDrop }) {
  const latest = useRef({ accept, onDrop });
  latest.current = { accept, onDrop };
  const { setNodeRef, isOver, active } = useDroppable({
    id,
    data: {
      onDrop: (item, x, y) => latest.current.accept(item.kind) && latest.current.onDrop(item, x, y),
    },
  });
  const accepting = Boolean(active && latest.current.accept(active.data.current?.kind));
  return { setNodeRef, isOver: isOver && accepting, accepting };
}
