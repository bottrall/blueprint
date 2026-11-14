const message =
  "Avoid type casts — prefer as const, satisfies, type guards, or assertion functions.";

// A const assertion (`as const`) stays allowed: it is not a type cast.
// It narrows to literal types without asserting an unverified shape.
function isConstAssertion(node) {
  const annotation = node.typeAnnotation;

  return (
    annotation?.type === "TSTypeReference" &&
    annotation.typeName?.type === "Identifier" &&
    annotation.typeName.name === "const"
  );
}

export default {
  meta: {
    type: "suggestion",
    docs: { description: "Disallow TypeScript type cast expressions." },
  },
  create(context) {
    return {
      TSAsExpression: (node) => {
        if (isConstAssertion(node)) {
          return;
        }

        context.report({ node, message });
      },
      TSTypeAssertion: (node) => context.report({ node, message }),
    };
  },
};
