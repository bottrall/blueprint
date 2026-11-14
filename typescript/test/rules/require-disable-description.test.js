import { describeRule } from "../support/rule-fixtures.js";

describeRule("require-disable-description", {
  messages: ["A lint disable directive must explain why — add ` -- <reason>` after the rule."],
});
