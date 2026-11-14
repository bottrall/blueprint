import assert from "node:assert/strict";
import { readFileSync } from "node:fs";
import path from "node:path";
import { describe, it } from "node:test";

import plugin from "../plugin/index.js";
import { packageRoot, runOxlint } from "./support/oxlint.js";

const consumersRoot = path.join(packageRoot, "test", "fixtures", "consumers");

function lintConsumer(name) {
  const cwd = path.join(consumersRoot, name);
  return runOxlint({ cwd, config: path.join(cwd, "oxlintrc.json"), targets: ["."] });
}

function rulesIn(diagnostics, file) {
  return new Set(
    diagnostics.filter((diagnostic) => diagnostic.file === file).map(({ rule }) => rule),
  );
}

function readConfig(name) {
  return JSON.parse(readFileSync(path.join(packageRoot, "oxlint", name), "utf8"));
}

function configuredRules(config) {
  return [
    ...Object.keys(config.rules ?? {}),
    ...(config.overrides ?? []).flatMap((override) => Object.keys(override.rules ?? {})),
  ];
}

describe("oxlint/base.json, extended by a plain consumer", () => {
  const diagnostics = lintConsumer("base");

  it("applies the universal bottrall rules", () => {
    assert.deepEqual(
      ["no-inheritance", "no-screaming-case", "require-disable-description"]
        .map((rule) => `bottrall(${rule})`)
        .filter((rule) => !rulesIn(diagnostics, "tool.js").has(rule)),
      [],
    );
  });

  it("applies the TypeScript rules to TypeScript files", () => {
    assert.deepEqual(
      [
        "typescript(no-explicit-any)",
        "bottrall(no-explicit-return-types)",
        "bottrall(no-type-casts)",
      ].filter((rule) => !rulesIn(diagnostics, "typed.ts").has(rule)),
      [],
    );
  });

  it("reports unused disable directives", () => {
    assert.ok(
      diagnostics.some(
        ({ file, message }) => file === "tool.js" && message.startsWith("Unused eslint-disable"),
      ),
    );
  });
});

describe("oxlint/app.json, extended by a Preact app consumer", () => {
  const diagnostics = lintConsumer("app");

  it("applies the consumer's source override to files it covers", () => {
    assert.ok(rulesIn(diagnostics, "src/badge.tsx").has("bottrall(no-default-export)"));
  });

  it("leaves files outside the consumer's source override alone", () => {
    assert.equal(rulesIn(diagnostics, "vite.config.ts").has("bottrall(no-default-export)"), false);
  });

  it("requires colocated tests inside the consumer's source override", () => {
    assert.ok(rulesIn(diagnostics, "src/untested.ts").has("bottrall(require-colocated-test)"));
  });

  it("turns away imports from react", () => {
    assert.ok(rulesIn(diagnostics, "src/badge.tsx").has("eslint(no-restricted-imports)"));
  });

  it("lints Tailwind classes in class, className and cx()", () => {
    assert.deepEqual(
      [
        "better-tailwindcss(no-conflicting-classes)",
        "better-tailwindcss(no-unknown-classes)",
        "better-tailwindcss(no-duplicate-classes)",
      ].filter((rule) => !rulesIn(diagnostics, "src/badge.tsx").has(rule)),
      [],
    );
  });

  it("reads the Tailwind entry point from the consumer's settings", () => {
    assert.equal(
      diagnostics.some(({ message }) => message.includes("brand-glow")),
      false,
    );
  });

  it("flags class values Tailwind lint cannot see", () => {
    assert.ok(rulesIn(diagnostics, "src/badge.tsx").has("bottrall(no-unlintable-classes)"));
  });

  it("applies the vitest, Testing Library and jest-dom rules to unit tests", () => {
    assert.deepEqual(
      [
        "bottrall(no-mocking)",
        "vitest(max-expects)",
        "testing-library(prefer-screen-queries)",
        "jest-dom(prefer-to-have-attribute)",
      ].filter((rule) => !rulesIn(diagnostics, "src/badge.test.tsx").has(rule)),
      [],
    );
  });

  it("keeps the unit-test rules off Playwright specs", () => {
    assert.deepEqual([...rulesIn(diagnostics, "e2e/smoke.spec.ts")], []);
  });
});

describe("the shipped configs", () => {
  it("only name bottrall rules the plugin defines", () => {
    assert.deepEqual(
      [...configuredRules(readConfig("base.json")), ...configuredRules(readConfig("app.json"))]
        .filter((rule) => rule.startsWith("bottrall/"))
        .filter((rule) => !Object.hasOwn(plugin.rules, rule.slice("bottrall/".length))),
      [],
    );
  });

  it("give every better-tailwindcss rule but class order the same selectors", () => {
    const { rules } = readConfig("app.json");
    const selectorSets = Object.entries(rules)
      .filter(([rule]) => rule.startsWith("better-tailwindcss/"))
      .filter(([rule]) => rule !== "better-tailwindcss/enforce-consistent-class-order")
      .map(([, setting]) => JSON.stringify(setting[1]?.selectors));
    assert.equal(new Set(selectorSets).size, 1);
  });
});
