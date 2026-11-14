import { describeRule } from "../support/rule-fixtures.js";

describeRule("no-default-export", {
  messages: ["Use a named export — default exports aren't refactor-safe or grep-able."],
});
