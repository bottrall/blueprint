export function add(left: number, right: number) {
  return left + right;
}

export const double = (value: number) => value * 2;

export function isText(value: unknown): value is string {
  return typeof value === "string";
}

export function assertText(value: unknown): asserts value is string {
  if (typeof value !== "string") {
    throw new TypeError("expected text");
  }
}

export function assertPresent(value: unknown): asserts value {
  if (!value) {
    throw new TypeError("expected a value");
  }
}
