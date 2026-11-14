import { signal } from "@preact/signals";
import { act, render, screen } from "@testing-library/preact";
import userEvent from "@testing-library/user-event";
import { describe, expect, it } from "vitest";

import { CounterScreen } from "./counter-screen.tsx";

const start = 2;

function setup() {
  const count = signal(start);
  const increments: number[] = [];
  render(<CounterScreen counter={{ count, increment: () => increments.push(count.value) }} />);
  return { count, increments, user: userEvent.setup() };
}

describe(CounterScreen, () => {
  it("shows the count", () => {
    setup();
    expect(screen.getByRole("status", { name: "Count" })).toHaveTextContent(String(start));
  });

  it("follows the count as it changes", () => {
    const { count } = setup();
    act(() => {
      count.value = start + 1;
    });
    expect(screen.getByRole("status", { name: "Count" })).toHaveTextContent(String(start + 1));
  });

  it("adds one on a click", async () => {
    const { increments, user } = setup();
    await user.click(screen.getByRole("button", { name: "Add one" }));
    expect(increments).toStrictEqual([start]);
  });
});
