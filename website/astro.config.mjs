import { defineConfig } from "astro/config";

// A plain static site: `astro build` writes HTML, CSS and JS to dist/.
export default defineConfig({
  site: "https://nightbar.app",
  output: "static",
});
