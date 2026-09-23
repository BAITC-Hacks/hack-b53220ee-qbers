import { useEffect, useId, useRef, useState } from "react";

export default function PortraitPreview({ src, alt, secondary = false }) {
  const id = useId();
  const trigger = useRef(null);
  const preview = useRef(null);
  const dismissTimer = useRef(null);
  const [open, setOpen] = useState(false);

  const cancelDismiss = () => clearTimeout(dismissTimer.current);
  const hide = () => {
    cancelDismiss();
    preview.current?.hidePopover();
  };
  const dismissSoon = () => {
    cancelDismiss();
    // Give the pointer time to cross the gap into the preview.
    dismissTimer.current = setTimeout(() => preview.current?.hidePopover(), 180);
  };

  function show() {
    cancelDismiss();
    const rect = trigger.current.getBoundingClientRect();
    const image = trigger.current.querySelector("img");
    const ratio = image.naturalWidth / image.naturalHeight || 3 / 4;
    const maxHeight = Math.min(420, window.innerHeight - 32);
    const width = Math.min(320, window.innerWidth - 32, (maxHeight - 20) * ratio + 20);
    const height = (width - 20) / ratio + 20;
    const fitsRight = rect.right + 12 + width <= window.innerWidth - 16;
    const fitsLeft = rect.left - 12 - width >= 16;
    const left = fitsRight ? rect.right + 12 : fitsLeft ? rect.left - 12 - width : rect.left;
    const top = fitsRight || fitsLeft ? rect.top + (rect.height - height) / 2 : rect.bottom + 12;
    Object.assign(preview.current.style, {
      width: `${width}px`,
      height: `${height}px`,
      left: `${Math.max(16, Math.min(left, window.innerWidth - width - 16))}px`,
      top: `${Math.max(16, Math.min(top, window.innerHeight - height - 16))}px`,
    });
    preview.current.showPopover();
  }

  useEffect(() => () => clearTimeout(dismissTimer.current), []);
  useEffect(() => {
    if (!open) return undefined;
    const close = () => preview.current?.hidePopover();
    window.addEventListener("scroll", close, true);
    window.addEventListener("resize", close);
    return () => {
      window.removeEventListener("scroll", close, true);
      window.removeEventListener("resize", close);
    };
  }, [open]);

  return (
    <>
      <button ref={trigger} type="button"
        className={`contact-portrait${secondary ? " contact-portrait--second" : ""}`}
        aria-label={`View full photo: ${alt}`} aria-describedby={open ? id : undefined}
        onPointerEnter={(event) => { if (event.pointerType !== "touch") show(); }}
        onPointerLeave={dismissSoon} onFocus={show} onBlur={hide} onClick={show}>
        <img src={src} alt={alt} width={secondary ? 96 : 160} height={secondary ? 96 : 160} loading="lazy" />
      </button>
      {/* The popover top layer escapes the card's rounded overflow clipping.
          Auto popovers also provide Escape, outside-click and one-at-a-time dismissal. */}
      <div ref={preview} id={id} className="contact-photo-tooltip" popover="auto" role="tooltip"
        onToggle={(event) => setOpen(event.newState === "open")}
        onPointerEnter={cancelDismiss} onPointerLeave={dismissSoon}>
        <img src={src} alt={alt} loading="lazy" />
      </div>
    </>
  );
}
