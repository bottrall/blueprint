import noDefaultExport from "./rules/no-default-export.js";
import noExplicitReturnTypes from "./rules/no-explicit-return-types.js";
import noInheritance from "./rules/no-inheritance.js";
import noMocking from "./rules/no-mocking.js";
import noScreamingCase from "./rules/no-screaming-case.js";
import noTypeCasts from "./rules/no-type-casts.js";
import noUnlintableClasses from "./rules/no-unlintable-classes.js";
import requireColocatedTest from "./rules/require-colocated-test.js";
import requireDisableDescription from "./rules/require-disable-description.js";

// A rule's lint id is `<meta.name>/<key>` — e.g. `bottrall/no-explicit-return-types`.
export default {
  meta: { name: "bottrall" },
  rules: {
    "no-default-export": noDefaultExport,
    "no-explicit-return-types": noExplicitReturnTypes,
    "no-inheritance": noInheritance,
    "no-mocking": noMocking,
    "no-screaming-case": noScreamingCase,
    "no-type-casts": noTypeCasts,
    "no-unlintable-classes": noUnlintableClasses,
    "require-colocated-test": requireColocatedTest,
    "require-disable-description": requireDisableDescription,
  },
};
