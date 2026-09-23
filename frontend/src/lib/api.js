function csrfToken() {
  return document.cookie.match(/(?:^|; )csrftoken=([^;]+)/)?.[1] ?? "";
}

// Django sets the csrftoken cookie from /api/csrf/; fetch it once before the first write.
let csrfReady;
function ensureCsrf() {
  csrfReady ??= csrfToken() ? Promise.resolve() : fetch("/api/csrf/", { credentials: "same-origin" });
  return csrfReady;
}

export async function api(path, { method = "GET", body } = {}) {
  if (method !== "GET") await ensureCsrf();
  const res = await fetch(`/api/${path}`, {
    method,
    credentials: "same-origin",
    headers: body ? { "Content-Type": "application/json", "X-CSRFToken": csrfToken() } : {},
    body: body ? JSON.stringify(body) : undefined,
  });
  const data = await res.json().catch(() => ({}));
  if (!res.ok) throw Object.assign(new Error(data.error || res.statusText), { data });
  return data;
}
