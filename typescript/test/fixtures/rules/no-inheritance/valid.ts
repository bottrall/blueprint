export class NotFoundError extends Error {}

export class ValidationError extends TypeError {}

export class MissingRecordError extends NotFoundError {}

export class Plain {}

export const Standalone = class {};
