import { StrictMode } from "react";
import { createRoot } from "react-dom/client";
import App from "./App";
import { loadAnalytics, loadFonts } from "./lib/bootstrap";
import "./styles.css";

loadFonts();
loadAnalytics();

createRoot(document.getElementById("root")).render(
  <StrictMode>
    <App />
  </StrictMode>
);
