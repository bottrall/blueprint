const message = "A lint disable directive must explain why — add ` -- <reason>` after the rule.";

const directive = /^\s*(?:oxlint|eslint)-disable(?:-next-line|-line)?(?:\s|$)/u;

// The `--` separator introduces the human-readable reason.
// Without it, oxlint reads the trailing text as rule names and mis-parses the directive.
const description = /\s--\s*\S/u;

function lacksDescription(comment) {
  return directive.test(comment.value) && !description.test(comment.value);
}

export default {
  meta: {
    type: "suggestion",
    docs: { description: "Require a description on lint disable directives." },
  },
  create(context) {
    return {
      Program: () =>
        context.sourceCode
          .getAllComments()
          .filter((comment) => lacksDescription(comment))
          .forEach((comment) => context.report({ loc: comment.loc, message })),
    };
  },
};
