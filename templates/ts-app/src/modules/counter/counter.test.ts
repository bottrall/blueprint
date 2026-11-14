import { describe, expect, it } from "vitest";

import { counter } from "./counter.ts";

const saved = 3;

function fakeStorage(entries: Record<string, string> = {}) {
  const items = new Map(Object.entries(entries));
  return {
    items,
    getItem: (key: string) => items.get(key) ?? null,
    setItem: (key: string, value: string) => {
      items.set(key, value);
    },
  };
}

describe(counter, () => {
  it("starts from the saved count", () => {
    expect(counter(fakeStorage({ count: String(saved) }), "count").count.value).toBe(saved);
  });

  it("starts from zero when nothing is saved", () => {
    expect(counter(fakeStorage(), "count").count.value).toBe(0);
  });

  it("starts from zero when the saved count isn't a whole number", () => {
    expect(counter(fakeStorage({ count: "1.5" }), "count").count.value).toBe(0);
  });

  it("adds one", () => {
    const tally = counter(fakeStorage(), "count");
    tally.increment();
    expect(tally.count.value).toBe(1);
  });

  it("saves the new count under its key", () => {
    const storage = fakeStorage({ count: String(saved) });
    counter(storage, "count").increment();
    expect(storage.items.get("count")).toBe(String(saved + 1));
  });
});
