import { describe, expect, it } from "vitest";

import { cx } from "./cx.ts";

describe(cx, () => {
  it("joins truthy class values and drops falsy ones", () => {
    expect(cx("flex", false, undefined, "hidden", null)).toBe("flex hidden");
  });
});
