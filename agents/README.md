# Shared AGENTS.md sections

Each file here is one section of a project's `AGENTS.md`, written once so every repo states the rule the same way. Each starts with its own `## Heading`, so it drops into an `AGENTS.md` as a whole section.

| File             | Section                                                             | For             |
| ---------------- | ------------------------------------------------------------------- | --------------- |
| `commands.md`    | `## Commands`: everything runs through `bin/`, and the `bin/` table | every repo      |
| `code-style.md`  | `## Code style`, with `### Dependency injection`                    | every repo      |
| `testing.md`     | `## Testing`                                                        | every repo      |
| `ruby-typing.md` | `## Ruby typing`: Steep, rbs-inline and `sig/`                      | repos with Ruby |
| `comments.md`    | `## Comments and documentation`                                     | every repo      |

## Order

`AGENTS.md` copies each file in whole, heading included, in this order, so every repo's reads the same way: what to run, where things go, then how to write, test, type and comment the code. The repo's own sections (layout, releasing, stack rules) go after `## Commands`.

```md
# <name>

<one-sentence description>

<agents/commands.md, with rows for bin/ scripts the repo doesn't have deleted>

## Layout

<the repo's own sections>

<agents/code-style.md>

<agents/testing.md>

<agents/ruby-typing.md, Ruby repos only>

<agents/comments.md>
```

The files hold no placeholders, so they read the same in every repo.
