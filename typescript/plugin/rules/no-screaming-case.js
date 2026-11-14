const message =
  "Use camelCase for values — no SCREAMING_CASE. Module-level constants are camelCase too.";

// All-caps (with optional underscores/digits), e.g. FOO or MAX_RETRIES — but not
// PascalCase, which has lowercase letters and is reserved for types and components.
function isScreaming(name) {
  return name.length > 1 && /[A-Z]/u.test(name) && name === name.toUpperCase();
}

export default {
  meta: {
    type: "suggestion",
    docs: { description: "Disallow SCREAMING_CASE value identifiers — values are camelCase." },
  },
  create(context) {
    // Skip ambient `.d.ts` declarations.
    // They name external or injected globals (e.g. Vite `define` build constants) that keep their own SCREAMING convention.
    const filename = context.physicalFilename ?? context.filename;
    if (filename?.endsWith(".d.ts")) {
      return {};
    }

    return {
      VariableDeclarator: (node) => {
        if (node.id.type === "Identifier" && isScreaming(node.id.name)) {
          context.report({ node: node.id, message });
        }
      },
    };
  },
};
