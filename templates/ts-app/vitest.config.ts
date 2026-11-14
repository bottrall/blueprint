import { defineConfig, mergeConfig } from "vitest/config";

import viteConfig from "./vite.config.ts";

// Inherit the Vite config (the `~` alias, Preact, Tailwind) so tests run the real transform pipeline.
export default mergeConfig(
  viteConfig,
  defineConfig({
    test: {
      environment: "happy-dom",
      globals: false,
      restoreMocks: true,
      setupFiles: ["./test/setup.ts"],
      include: ["src/**/*.test.{ts,tsx}"],
      coverage: {
        provider: "v8",
        reporter: ["text"],
        include: ["src/**/*.{ts,tsx}"],
        exclude: ["**/*.test.{ts,tsx}", "**/*.d.ts", "src/main.tsx"],
        thresholds: {
          perFile: true,
          functions: 100,
          statements: 75,
        },
      },
    },
  }),
);
