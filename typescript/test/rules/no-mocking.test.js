import { describeRule } from "../support/rule-fixtures.js";

describeRule("no-mocking", {
  messages: [
    "Don't mock code you own — inject a real lightweight fake instead. Mock a genuine third-party only at its API boundary, in the global test setup.",
  ],
});
