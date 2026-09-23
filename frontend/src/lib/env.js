// Single place the frontend reads configuration from `.env`.
export const env = {
  googleApiKey: import.meta.env.VITE_GOOGLE_API_KEY,
  googleClientId: import.meta.env.VITE_GOOGLE_OAUTH_CLIENT_ID,
  gaMeasurementId: import.meta.env.VITE_GA_MEASUREMENT_ID,
  fontSans: import.meta.env.VITE_FONT_SANS || "Rubik",
  fontSerif: import.meta.env.VITE_FONT_SERIF || "EB Garamond",
};
