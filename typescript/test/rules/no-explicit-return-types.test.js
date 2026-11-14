import { describeRule } from "../support/rule-fixtures.js";

describeRule("no-explicit-return-types", {
  messages: ["Do not annotate function return types — let them be inferred."],
});
