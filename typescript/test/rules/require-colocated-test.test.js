import { describeRule } from "../support/rule-fixtures.js";

describeRule("require-colocated-test", {
  messages: [
    "This module exports behavior but has no colocated test — add a sibling `*.test` file.",
  ],
});
