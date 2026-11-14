import { vi } from "vitest";

vi.mock("./collaborator.ts"); // ✗

vi.doMock("./collaborator.ts"); // ✗

vi.spyOn(console, "log"); // ✗
