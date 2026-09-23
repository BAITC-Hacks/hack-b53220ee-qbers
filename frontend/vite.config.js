import { defineConfig } from "vite";
import react from "@vitejs/plugin-react";

// `.env` lives at the repo root so Django and React share one file.
// Only variables prefixed with VITE_ are exposed to the browser.
// run.sh sets DJANGO_PORT if 8000 is already taken.
const django = `http://127.0.0.1:${process.env.DJANGO_PORT || 8000}`;

export default defineConfig({
  envDir: "..",
  plugins: [react()],
  server: {
    port: 5173,
    strictPort: true,
    proxy: {
      "/api": django,
      "/admin": django,
      "/static": django,
    },
  },
});
