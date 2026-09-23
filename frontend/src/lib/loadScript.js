const cache = new Map();

export function loadScript(src, attrs = {}) {
  if (!cache.has(src)) {
    cache.set(
      src,
      new Promise((resolve, reject) => {
        const el = document.createElement("script");
        el.src = src;
        el.async = true;
        Object.assign(el, attrs);
        el.onload = resolve;
        el.onerror = () => reject(new Error(`Failed to load ${src}`));
        document.head.appendChild(el);
      })
    );
  }
  return cache.get(src);
}
