const classBearingName = /^\w*[cC]lass(?:es|Names?)$/u;

// Preact takes `class`; React-style `className` works too. Both feed the Tailwind lint selectors.
const classAttributes = new Set(["class", "className"]);

const attributeMessage =
  "class / className must be a string literal or a cx() call — anything else hides its classes from Tailwind lint.";

const argumentMessage =
  "cx() arguments must be visible to Tailwind lint: a string, a conditional over strings, a nested cx() call, or a reference named class / className or ending in classes.";

function isStringLiteral(node) {
  return (
    (node.type === "Literal" && typeof node.value === "string") ||
    node.type === "StringLiteral" ||
    (node.type === "TemplateLiteral" && node.expressions.length === 0)
  );
}

function isFalsyLiteral(node) {
  return (
    (node.type === "Literal" && (node.value === false || node.value === null)) ||
    (node.type === "Identifier" && node.name === "undefined")
  );
}

function isCxCall(node) {
  return (
    node.type === "CallExpression" && node.callee.type === "Identifier" && node.callee.name === "cx"
  );
}

function isClassBearingReference(node) {
  if (node.type === "Identifier") {
    return classBearingName.test(node.name);
  }
  if (node.type === "MemberExpression") {
    return (
      (node.object.type === "Identifier" && classBearingName.test(node.object.name)) ||
      (!node.computed &&
        node.property.type === "Identifier" &&
        classAttributes.has(node.property.name))
    );
  }
  return false;
}

function isVisibleArgument(node) {
  if (
    isStringLiteral(node) ||
    isFalsyLiteral(node) ||
    isClassBearingReference(node) ||
    isCxCall(node)
  ) {
    return true;
  }
  if (node.type === "ConditionalExpression") {
    return isVisibleArgument(node.consequent) && isVisibleArgument(node.alternate);
  }
  if (node.type === "LogicalExpression") {
    return node.operator === "&&"
      ? isVisibleArgument(node.right)
      : isVisibleArgument(node.left) && isVisibleArgument(node.right);
  }
  return false;
}

export default {
  meta: {
    type: "problem",
    docs: {
      description:
        "Require class / className values and cx() arguments to be string literals or references the Tailwind lint selectors scan, so no class string escapes validation.",
    },
  },
  create(context) {
    return {
      JSXAttribute: (node) => {
        if (
          node.name.type !== "JSXIdentifier" ||
          !classAttributes.has(node.name.name) ||
          !node.value
        ) {
          return;
        }
        if (isStringLiteral(node.value)) {
          return;
        }
        if (node.value.type === "JSXExpressionContainer") {
          const { expression } = node.value;
          if (isStringLiteral(expression) || isCxCall(expression)) {
            return;
          }
        }
        context.report({ node: node.value, message: attributeMessage });
      },
      CallExpression: (node) => {
        if (!isCxCall(node)) {
          return;
        }
        for (const argument of node.arguments) {
          if (!isVisibleArgument(argument)) {
            context.report({ node: argument, message: argumentMessage });
          }
        }
      },
    };
  },
};
