import { describeRule } from "../support/rule-fixtures.js";

describeRule("no-inheritance", {
  messages: [
    'Compose, don\'t inherit — pass collaborators in and share shape via an interface. Extend only a custom Error; for a genuine "is-a" with shared implementation, add a scoped disable with a reason.',
  ],
});
