const mockingMethods = new Set(["mock", "doMock", "spyOn"]);

const message =
  "Don't mock code you own — inject a real lightweight fake instead. Mock a genuine third-party only at its API boundary, in the global test setup.";

function isMockingCall(callee) {
  return (
    callee.type === "MemberExpression" &&
    callee.object.type === "Identifier" &&
    callee.object.name === "vi" &&
    callee.property.type === "Identifier" &&
    mockingMethods.has(callee.property.name)
  );
}

export default {
  meta: {
    type: "suggestion",
    docs: {
      description:
        "Disallow mocking your own code — test against real collaborators, mocking third parties only at their API boundary.",
    },
  },
  create(context) {
    return {
      CallExpression: (node) => {
        if (isMockingCall(node.callee)) {
          context.report({ node, message });
        }
      },
    };
  },
};
