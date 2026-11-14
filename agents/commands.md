## Commands

Everything runs through its `bin/` script, never a tool directly (`rake`, `rubocop`, `steep`, `vitest`, `oxlint`, `tsc`, `vite`, `playwright`).

| Script                        | What it does                                                                    |
| ----------------------------- | ------------------------------------------------------------------------------- |
| `bin/setup`                   | Install dependencies on a fresh checkout                                        |
| `bin/dev`                     | Run the app locally                                                             |
| `bin/test [paths]`            | Run the tests; pass files to run only those                                     |
| `bin/e2e [paths]`             | Run the end-to-end tests against a production build                             |
| `bin/lint [--fix] [paths]`    | Check lint and formatting; `--fix` fixes what it can                            |
| `bin/typecheck`               | Type-check the code                                                             |
| `bin/generate [--watch]`      | Regenerate the generated files; `--watch` keeps them current                    |
| `bin/build`                   | Build what the repo ships                                                       |
| `bin/docs [--serve\|--check]` | Build the docs; `--serve` serves them, `--check` checks them                    |
| `bin/check`                   | `bin/lint --fix`, `bin/typecheck`, `bin/test`: run before calling a change done |
| `bin/ci`                      | Run exactly what CI runs, without fixes: run before pushing                     |
