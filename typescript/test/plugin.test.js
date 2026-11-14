import assert from "node:assert/strict";
import { describe, it } from "node:test";

import plugin from "../plugin/index.js";

describe("plugin", () => {
  it("is named bottrall", () => {
    assert.equal(plugin.meta.name, "bottrall");
  });

  it("defines the nine shared rules", () => {
    assert.deepEqual(Object.keys(plugin.rules).toSorted(), [
      "no-default-export",
      "no-explicit-return-types",
      "no-inheritance",
      "no-mocking",
      "no-screaming-case",
      "no-type-casts",
      "no-unlintable-classes",
      "require-colocated-test",
      "require-disable-description",
    ]);
  });
});
