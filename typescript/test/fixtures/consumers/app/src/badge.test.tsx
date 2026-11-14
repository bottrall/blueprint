import { render } from "@testing-library/preact";
import { describe, expect, it, vi } from "vitest";

import Badge from "./badge.tsx";

vi.mock("./badge.tsx");

describe("Badge", () => {
  it("renders", () => {
    const { getByRole } = render(<Badge active />);
    expect(getByRole("list").getAttribute("id")).toBe("x");
    expect(getByRole("list")).toBeDefined();
  });
});
