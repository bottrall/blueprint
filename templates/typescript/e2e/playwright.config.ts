import { fileURLToPath } from "node:url";

import { defineConfig, devices } from "@playwright/test";

const port = 4173;

export default defineConfig({
  testDir: ".",
  // Pin artifacts beside this config so they land under e2e/ whatever cwd Playwright is launched from.
  outputDir: fileURLToPath(new URL("test-results", import.meta.url)),
  fullyParallel: true,
  forbidOnly: Boolean(process.env.CI),
  retries: process.env.CI ? 1 : 0,
  reporter: process.env.CI ? "github" : "list",
  use: {
    baseURL: `http://localhost:${port}`,
    trace: "on-first-retry",
  },
  projects: [{ name: "chromium", use: { ...devices["Desktop Chrome"] } }],
  // The app is tested as it ships: built, then served from dist/, so a broken build fails the suite.
  webServer: {
    command: "pnpm exec vite build && pnpm exec vite preview",
    cwd: "..",
    url: `http://localhost:${port}`,
    reuseExistingServer: !process.env.CI,
  },
});
