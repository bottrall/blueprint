export function add(left: number, right: number): number { // ✗
  return left + right;
}

export const double = (value: number): number => value * 2; // ✗

export const triple = function (value: number): number { // ✗
  return value * 3;
};

export const calculator = {
  halve(value: number): number { // ✗
    return value / 2;
  },
};
