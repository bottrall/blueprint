const raw: unknown = "text";

export const viaAs = raw as string; // ✗

export const viaAngleBrackets = <string>raw; // ✗

export const viaUnknown = (raw as unknown) satisfies unknown; // ✗
