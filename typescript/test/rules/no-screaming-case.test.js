import { describeRule } from "../support/rule-fixtures.js";

describeRule("no-screaming-case", {
  messages: [
    "Use camelCase for values — no SCREAMING_CASE. Module-level constants are camelCase too.",
  ],
});
