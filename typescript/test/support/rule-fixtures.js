import assert from "node:assert/strict";
import { readdirSync, readFileSync } from "node:fs";
import path from "node:path";
import { describe, it } from "node:test";

import { packageRoot, runOxlint } from "./oxlint.js";

const fixturesRoot = path.join(packageRoot, "test", "fixtures", "rules");
const marker = "✗";

function markedLines(file) {
  return readFileSync(path.join(fixturesRoot, file), "utf8")
    .split("\n")
    .flatMap((text, index) => (text.includes(marker) ? [index + 1] : []));
}

function reportedLines(diagnostics, file) {
  return diagnostics
    .filter((diagnostic) => diagnostic.file === file)
    .map((diagnostic) => diagnostic.line)
    .toSorted((left, right) => left - right);
}

function fixtureFiles(rule) {
  return readdirSync(path.join(fixturesRoot, rule))
    .filter((name) => /\.[cm]?[jt]sx?$/u.test(name))
    .map((name) => `${rule}/${name}`);
}

function isInvalid(file) {
  return path.basename(file).startsWith("invalid");
}

// Lint a rule's fixture directory once and generate one test per fixture file.
// A file named `invalid*` must be reported on exactly the lines containing `✗`.
// Any other file must not be reported at all.
// Every report must carry one of the rule's documented messages.
export function describeRule(rule, { messages }) {
  const diagnostics = runOxlint({
    cwd: fixturesRoot,
    config: path.join(fixturesRoot, "oxlintrc.json"),
    targets: [rule],
  }).filter((diagnostic) => diagnostic.rule === `bottrall(${rule})`);

  describe(`bottrall/${rule}`, () => {
    fixtureFiles(rule)
      .filter((file) => isInvalid(file))
      .forEach((file) => {
        it(`reports exactly the marked lines in ${file}`, () => {
          assert.deepEqual(reportedLines(diagnostics, file), markedLines(file));
        });
      });

    fixtureFiles(rule)
      .filter((file) => !isInvalid(file))
      .forEach((file) => {
        it(`reports nothing in ${file}`, () => {
          assert.deepEqual(reportedLines(diagnostics, file), []);
        });
      });

    it("reports only with the rule's messages", () => {
      assert.deepEqual(
        [...new Set(diagnostics.map((diagnostic) => diagnostic.message))].toSorted(),
        messages.toSorted(),
      );
    });
  });
}
