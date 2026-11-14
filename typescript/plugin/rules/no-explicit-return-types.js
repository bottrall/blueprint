const message = "Do not annotate function return types — let them be inferred.";

function check(context, node) {
  const annotation = node.returnType?.typeAnnotation;

  if (!annotation) {
    return;
  }

  // A type predicate (`x is T`) or assertion signature (`asserts x`) must stay explicit.
  // Inference collapses it to `boolean`, which destroys the guard.
  if (annotation.type === "TSTypePredicate") {
    return;
  }

  context.report({ node: node.returnType, message });
}

export default {
  meta: {
    type: "suggestion",
    docs: { description: "Disallow explicit function return type annotations." },
  },
  create(context) {
    return {
      FunctionDeclaration: (node) => check(context, node),
      FunctionExpression: (node) => check(context, node),
      ArrowFunctionExpression: (node) => check(context, node),
    };
  },
};
