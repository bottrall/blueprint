const message = "Use a named export — default exports aren't refactor-safe or grep-able.";

export default {
  meta: {
    type: "suggestion",
    docs: { description: "Disallow default exports; use named exports." },
  },
  create(context) {
    return {
      ExportDefaultDeclaration: (node) => {
        context.report({ node, message });
      },
    };
  },
};
