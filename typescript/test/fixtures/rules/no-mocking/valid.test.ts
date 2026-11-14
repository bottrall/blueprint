import { vi } from "vitest";

const fakeClock = vi.fn(() => 0);

vi.useFakeTimers();

export { fakeClock };
