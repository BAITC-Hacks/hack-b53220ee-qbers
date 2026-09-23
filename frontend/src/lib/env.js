// Single place the frontend reads configuration from `.env` (only VITE_* values reach the browser).
export const env = {
  dgisKey: import.meta.env.VITE_DGIS_API_KEY,
  gaMeasurementId: import.meta.env.VITE_GA_MEASUREMENT_ID,
  fontSans: import.meta.env.VITE_FONT_SANS || "Rubik",
  fontSerif: import.meta.env.VITE_FONT_SERIF || "EB Garamond",
};
