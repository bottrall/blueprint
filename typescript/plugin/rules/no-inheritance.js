const message =
  'Compose, don\'t inherit — pass collaborators in and share shape via an interface. Extend only a custom Error; for a genuine "is-a" with shared implementation, add a scoped disable with a reason.';

function isCustomError(superClass) {
  return superClass.type === "Identifier" && superClass.name.endsWith("Error");
}

export default {
  meta: {
    type: "suggestion",
    docs: {
      description:
        "Disallow class inheritance — compose collaborators and share shape via interfaces, extending only Error subclasses.",
    },
  },
  create(context) {
    function check(node) {
      if (node.superClass && !isCustomError(node.superClass)) {
        context.report({ node: node.superClass, message });
      }
    }

    return {
      ClassDeclaration: check,
      ClassExpression: check,
    };
  },
};
