import { signal } from "@preact/signals";
import { render, screen } from "@testing-library/preact";
import userEvent from "@testing-library/user-event";
import { describe, expect, it } from "vitest";

import { App } from "./app.tsx";

const counter = { count: signal(0), increment: () => null };

function setup(path = "/") {
  history.replaceState(null, "", path);
  render(<App counter={counter} />);
  return { user: userEvent.setup() };
}

describe(App, () => {
  it("starts at home", () => {
    setup();
    expect(screen.getByRole("heading", { level: 1 })).toHaveTextContent("{{name}}");
  });

  it("goes to the counter", async () => {
    const { user } = setup();
    await user.click(screen.getByRole("link", { name: "Counter" }));
    await expect(screen.findByRole("heading", { name: "Counter" })).resolves.toBeInTheDocument();
  });

  it("says when a page doesn't exist", () => {
    setup("/nowhere");
    expect(screen.getByRole("heading", { level: 1 })).toHaveTextContent("Page not found");
  });
});
