import { describeRule } from "../support/rule-fixtures.js";

describeRule("no-unlintable-classes", {
  messages: [
    "class / className must be a string literal or a cx() call — anything else hides its classes from Tailwind lint.",
    "cx() arguments must be visible to Tailwind lint: a string, a conditional over strings, a nested cx() call, or a reference named class / className or ending in classes.",
  ],
});
