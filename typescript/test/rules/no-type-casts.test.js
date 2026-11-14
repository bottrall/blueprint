import { describeRule } from "../support/rule-fixtures.js";

describeRule("no-type-casts", {
  messages: ["Avoid type casts — prefer as const, satisfies, type guards, or assertion functions."],
});
