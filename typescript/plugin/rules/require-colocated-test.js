import fs from "node:fs";
import path from "node:path";

const message =
  "This module exports behavior but has no colocated test — add a sibling `*.test` file.";

// Behavior the testing doc requires a test for: function, component, and class declarations.
// Plain values, type aliases, and re-exports carry none, so files holding only those are exempt.
const callableTypes = new Set([
  "FunctionDeclaration",
  "ClassDeclaration",
  "ArrowFunctionExpression",
  "FunctionExpression",
]);

function isExempt(filename, exemptSuffixes) {
  if (/\.(?:test|spec)\.[cm]?[jt]sx?$/u.test(filename)) {
    return true;
  }
  if (filename.endsWith(".d.ts")) {
    return true;
  }
  return exemptSuffixes.some((suffix) => filename === suffix || filename.endsWith(`/${suffix}`));
}

function isCallable(declaration) {
  if (!declaration) {
    return false;
  }
  if (callableTypes.has(declaration.type)) {
    return true;
  }
  if (declaration.type === "VariableDeclaration") {
    return declaration.declarations.some(
      (declarator) =>
        declarator.init?.type === "ArrowFunctionExpression" ||
        declarator.init?.type === "FunctionExpression",
    );
  }
  return false;
}

function exportsBehavior(body) {
  return body.some((statement) => {
    if (
      statement.type === "ExportNamedDeclaration" ||
      statement.type === "ExportDefaultDeclaration"
    ) {
      return isCallable(statement.declaration);
    }
    return false;
  });
}

const testSuffixes = ["test", "spec"].flatMap((kind) =>
  ["ts", "tsx", "mts", "cts", "js", "jsx", "mjs", "cjs"].map(
    (extension) => `.${kind}.${extension}`,
  ),
);

function hasColocatedTest(filename) {
  const extension = path.extname(filename);
  const base = filename.slice(0, -extension.length);
  return testSuffixes.some((suffix) => fs.existsSync(base + suffix));
}

export default {
  meta: {
    type: "suggestion",
    docs: { description: "Require a colocated test file for every module that exports behavior." },
    schema: [
      {
        type: "object",
        properties: { exempt: { type: "array", items: { type: "string" } } },
        additionalProperties: false,
      },
    ],
  },
  create(context) {
    const filename = context.physicalFilename ?? context.filename;
    const exemptSuffixes = context.options[0]?.exempt ?? [];

    return {
      Program: (node) => {
        if (!filename || isExempt(filename, exemptSuffixes)) {
          return;
        }
        if (!exportsBehavior(node.body)) {
          return;
        }
        if (hasColocatedTest(filename)) {
          return;
        }
        context.report({ node, message });
      },
    };
  },
};
