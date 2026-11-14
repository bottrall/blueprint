# Shared AGENTS.md sections

Each file here is one section of a project's `AGENTS.md`, written once so every repo states the rule the same way. Each starts with its own `## Heading`, so it drops into an `AGENTS.md` as a whole section.

| File             | Section                                                         | For                       |
| ---------------- | --------------------------------------------------------------- | ------------------------- |
| `commands.md`    | `## Commands`: everything runs through `bin/`, and the `bin/` table | every repo                |
| `code-style.md`  | `## Code style`, with `### Dependency injection`                 | every repo                |
| `testing.md`     | `## Testing`                                                    | every repo                |
| `ruby-typing.md` | `## Ruby typing`: Steep, rbs-inline and `sig/`                  | repos with Ruby           |
| `comments.md`    | `## Comments and documentation`                                 | every repo                |

## Including a section

A template's `AGENTS.md` pulls a section in with a line holding only the include:

```md
{{> agents/testing.md}}
```

When a project is created, that line is replaced by the file's whole content, heading included. The path is relative to the root of this repo. Sections specific to one stack or repo are written directly in the template's `AGENTS.md`, between the includes.

Includes are expanded after the template's placeholders are substituted, so the files here hold no `{{placeholders}}`: they read the same in every repo.

## Order

A template's `AGENTS.md` assembles them in this order, so every repo's file reads the same way: what to run, where things go, then how to write, test, type and comment the code.

```md
# {{name}}

{{description}}

{{> agents/commands.md}}

## Layout
<!-- the template's own sections: layout, workflow, release notes, stack rules -->

{{> agents/code-style.md}}

{{> agents/testing.md}}

{{> agents/ruby-typing.md}}

{{> agents/comments.md}}
```

Leave out the includes that don't apply (`ruby-typing.md` in a TS-only repo). After a project is created, delete the rows of its `## Commands` table for `bin/` scripts it doesn't have; each row stands alone.
