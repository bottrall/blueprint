class Base {}

const mixins = { Base };

export class Child extends Base {} // ✗

export const Anonymous = class extends Base {}; // ✗

export class Registry extends Map<string, number> {} // ✗

export class Mixed extends mixins.Base {} // ✗
