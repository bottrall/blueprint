# Shared template

The files every new repo gets, whatever its stack: the `bin/` scripts, the workflows and repo docs that are the same everywhere. A stack template (`templates/ruby-gem`, `templates/ruby-app`, `templates/ts-app`) is copied over this one to make a project.

| Path                               | What it is                                                                   |
| ---------------------------------- | ---------------------------------------------------------------------------- |
| `bin/`                             | The stack-aware scripts every task runs through; see [bin/](#bin)            |
| `bin/lib/stack.sh`                 | Stack detection and argument routing, sourced by the scripts                 |
| `.github/workflows/pr-title.yml`   | Checks PR titles are Conventional Commits                                    |
| `.github/workflows/deps.yml`       | Fixes and merges Renovate's branches once the `ci` workflow finishes on them |
| `.github/pull_request_template.md` | Problem / Solution / Proof                                                   |
| `renovate.json`                    | Renovate, configured by `bottrall/deps`                                      |
| `LICENSE`                          | MIT                                                                          |
| `CONTRIBUTING.md`                  | Setup, the `bin/` table, PR titles, releases                                 |
| `CODE_OF_CONDUCT.md`               | Contributor Covenant 2.1                                                     |
| `SECURITY.md`                      | Reporting a vulnerability through a GitHub security advisory                 |
| `template.json`                    | This template's placeholders, executables and excluded files                 |
| `test/`                            | Tests for the `bin/` scripts (not copied into projects)                      |

## Assembling a project

1. Copy `templates/shared/` into the new repo, leaving out the paths its `template.json` lists under `exclude`.
2. Copy the stack template over it. Where both have a file, the stack template's wins.
3. Delete the paths the stack template's `template.json` lists under `remove` (the `bin/` scripts that don't apply to that stack, for instance).
4. Substitute the placeholders, `{{name}}`, `{{module}}`, `{{require_path}}`, `{{description}}` and `{{year}}`, in every file's content and in every path that contains one.
5. Replace each line that holds only `{{> agents/<file>.md}}` with the content of that file from this repo's [`agents/`](../../agents/README.md).
6. Delete the rows of the `bin/` tables in `CONTRIBUTING.md` and `AGENTS.md` for the scripts step 3 removed. (`AGENTS.md`'s table only exists once step 5 has expanded `agents/commands.md`.)
7. Make every path listed under `executable` in either `template.json` executable.
8. In the new repo, run `bin/setup`, then `bin/lint --fix` (in a TS project it realigns the tables step 6 shortened, which oxfmt checks), then `bin/ci`.

### template.json

```json
{
  "placeholders": { "name": "The repo, gem or package name, e.g. riffer-rig" },
  "executable": ["bin/test"],
  "exclude": ["README.md", "template.json", "test"],
  "remove": ["bin/e2e"]
}
```

| Key            | Meaning                                                                           |
| -------------- | --------------------------------------------------------------------------------- |
| `placeholders` | Each placeholder the template's files and paths use, with what it stands for      |
| `executable`   | Paths, after substitution, to make executable                                     |
| `exclude`      | Paths in the template directory that are about the template, never copied         |
| `remove`       | Paths an earlier layer copied that this stack doesn't want (stack templates only) |

## bin/

`bin/` is the only way anything runs. One copy of each script serves Ruby-only, TS-only and mixed repos: it looks for a `Gemfile` (Ruby) and a `package.json` (TS) at the repo root and runs the side, or sides, it finds. Every script uses `#!/usr/bin/env bash` and `set -euo pipefail`, `cd`s to the repo root first (so it works from any directory), and says what it does in its first comment.

### What each script runs

| Script                        | Ruby (a `Gemfile`)                                              | TS (a `package.json`)                                                                            |
| ----------------------------- | --------------------------------------------------------------- | ------------------------------------------------------------------------------------------------ |
| `bin/setup`                   | `bundle install`, then `bundle exec rake setup`                 | `pnpm install`                                                                                   |
| `bin/dev`                     | `bundle exec rake dev`                                          | `pnpm exec mprocs` with an `mprocs.yaml`, else `pnpm exec vite`                                  |
| `bin/test [paths]`            | `bundle exec rake test`, with `TEST` and `TESTOPTS`             | `pnpm exec vitest run --coverage`; `vitest run` for some files; `vitest watch` with `--watch`    |
| `bin/e2e [paths]`             | —                                                               | `pnpm exec playwright test --config e2e/playwright.config.ts`                                    |
| `bin/lint [--fix] [paths]`    | `bundle exec rake lint`, with `RUBOCOP_OPTS` (`-a` for `--fix`) | `pnpm exec oxlint` and `pnpm exec oxfmt --check`; `oxlint --fix` and `oxfmt --write` for `--fix` |
| `bin/typecheck`               | `bundle exec rake typecheck`, with `STEEP_OPTS`                 | `pnpm exec tsc --noEmit`                                                                         |
| `bin/generate [--watch]`      | `bundle exec rake generate`; `generate:watch` with `--watch`    | —                                                                                                |
| `bin/build`                   | `bundle exec rake build`                                        | `pnpm exec vite build`                                                                           |
| `bin/docs [--serve\|--check]` | `bundle exec rake docs`; `docs:serve` or `docs:check`           | —                                                                                                |
| `bin/check`                   | `bin/lint --fix`, then `bin/typecheck`, then `bin/test`         | the same                                                                                         |
| `bin/ci`                      | each `bin/` script `.github/workflows/ci.yml` runs              | the same                                                                                         |

The Ruby side always goes through Rake, so a repo's `Rakefile` defines what each task does: `test` honours `TEST` (comma-separated files or globs) and `TESTOPTS`, `lint` runs RuboCop and honours `RUBOCOP_OPTS`, `typecheck` runs Steep and honours `STEEP_OPTS`.

### Choosing the stack

- **No arguments** runs every stack the repo has, Ruby first. In a mixed repo both always run, even when Ruby fails, and the script exits non-zero if either failed.
- **Paths** go to the stack that runs them, and only stacks that got a path start. In a single-stack repo every path goes to that stack. In a mixed repo:
  - `bin/test`: `.ts`, `.tsx` (and `.js`, `.jsx`, `.mts`, `.cts`, `.mjs`, `.cjs`) go to vitest; `.rb` files and anything under `test/` go to Minitest. A `.ts` file under `test/` goes to vitest. A directory given to Minitest becomes the glob `<dir>/**/*_test.rb`.
  - `bin/lint`: the same TS extensions go to oxlint and oxfmt; `.rb`, `.rake`, `.gemspec`, `.ru`, `Gemfile` and `Rakefile` go to RuboCop.
  - Any other path stops the script, before anything runs, with `can't tell whether <path> is Ruby or TS; pass --only=ruby or --only=ts`.
- **`--only=ruby`** or **`--only=ts`** runs just that stack, and every path goes to it. Naming a stack the repo doesn't have is an error.
- **Runner flags** (any argument starting with `-` that the script doesn't own) go to one runner, so they're allowed only when exactly one stack is selected: by `--only`, by the repo having one stack, or by the paths all going to one. Otherwise the script stops with `<flags> can only go to one stack's runner; pass --only=ruby or --only=ts`. The script-owned flags (`--fix`, `--watch`, `--serve`, `--check`, `--only`) are not runner flags.
- **`--watch`** on `bin/test` implies `--only=ts`: vitest watches, Minitest has no watcher. It's an error with `--only=ruby`. On `bin/generate`, which only Rake runs, `--watch` picks the `generate:watch` task instead.

These rules apply to `bin/test`, `bin/lint`, `bin/typecheck`, `bin/setup` and `bin/build`. The scripts that take no paths (`typecheck`, `setup`, `build`) pass every other argument to the runner as a flag, so `bin/build --only=ts --mode staging` runs `vite build --mode staging`.

### Flags and their values

In `bin/test` and `bin/lint`, a bare argument is a path, so a runner flag's value is joined to it with `=` (`--reporter=verbose`). These flags take their value as the next argument instead:

- `bin/test`: Minitest's `-n`/`--name`, `-s`/`--seed`, `-e`/`--exclude`, `-S`/`--skip`, and vitest's `-t`/`--testNamePattern`.
- `bin/lint`: RuboCop's `-f`/`--format`, `-o`/`--out`, `-c`/`--config`, `--except`.

For Minitest, a flag and its value are joined into one word in `TESTOPTS` (`--seed 1` becomes `--seed=1`, `-n /x/` becomes `-n/x/`), because Rake's test loader treats every word that doesn't start with `-` as a file.

Where the flags go:

| Script          | Ruby runner flags            | TS runner flags                        |
| --------------- | ---------------------------- | -------------------------------------- |
| `bin/test`      | `TESTOPTS`                   | `vitest`                               |
| `bin/lint`      | `RUBOCOP_OPTS`, before paths | `oxlint` (paths go to oxfmt as well)   |
| `bin/typecheck` | `STEEP_OPTS`                 | `tsc --noEmit`                         |
| `bin/setup`     | `bundle install`             | `pnpm install`                         |
| `bin/build`     | `rake build`                 | `vite build`                           |
| `bin/e2e`       | —                            | `playwright test`, with every argument |

### Coverage

`bin/test` measures coverage (`vitest run --coverage`) only on a whole, unfiltered run: no paths and no runner flags. Coverage thresholds are enforced per file, so a run of a few files would fail every file it didn't reach. `bin/ci` and `bin/check` run `bin/test` bare, so coverage is always enforced there.

### Scripts that don't apply

A script that has nothing to do in a repo says so on one line and exits 0, so a template can ship every script and `bin/ci` can run a script in any repo it's listed for:

| Script          | Does nothing when                                                                |
| --------------- | -------------------------------------------------------------------------------- |
| any             | there's neither a `Gemfile` nor a `package.json`                                 |
| `bin/typecheck` | skips Ruby with no `Steepfile`, and TS with no `tsconfig.json` (a plain-JS repo) |
| `bin/build`     | skips Ruby with no `rake build` task, and TS with no `vite.config.*`             |
| `bin/e2e`       | there's no `e2e/playwright.config.ts`                                            |
| `bin/dev`       | there's no `mprocs.yaml`, no `rake dev` task and no `vite.config.*`              |
| `bin/generate`  | there's no `Gemfile`, or no `rake generate` (`generate:watch`) task              |
| `bin/docs`      | there's no `Gemfile`, or no `rake docs` (`docs:serve`, `docs:check`) task        |

Rake tasks are found with `bundle exec rake -P`, which lists every task, described or not. The scripts a stack can't run are still better removed from a repo that never needs them (through the stack template's `remove`), so its `bin/` lists only what applies.

### bin/dev

`bin/dev` starts one long-running process: `pnpm exec mprocs` when the repo has a `package.json` and an `mprocs.yaml` (mprocs then starts the Ruby server too, in a mixed repo), else `bundle exec rake dev` when Rake has a `dev` task, else `pnpm exec vite` when there's a `vite.config.*`. It takes no arguments.

### bin/e2e

`bin/e2e` runs only Playwright. The app is tested as it ships: the Playwright config's `webServer` builds it with `vite build` and serves it with `vite preview`. Every argument (spec paths, `--project`, `-g`) goes to Playwright; `--only=ts` is accepted and `--only=ruby` is an error.

### bin/check

`bin/check` runs `bin/lint --fix`, `bin/typecheck` and `bin/test`, in that order, each even when one before it failed, and exits non-zero if any failed. It takes only `--only=ruby` or `--only=ts`, which it passes to all three.

### bin/ci

`bin/ci` runs exactly the scripts the repo's CI runs, read from `.github/workflows/ci.yml`: every line of the form `run: bin/<script> [args]` (a matrix entry's `run:` key or a step's), in the order they appear, each command once however many matrix entries repeat it. It skips `bin/setup`, which prepares a machine rather than checking code, and refuses a workflow whose command includes `--fix`, since CI never fixes. Every command runs even after one fails; the script then names the failures and exits 1. So a template's `ci.yml` must name each script literally:

```yaml
matrix:
  include:
    - name: lint
      run: bin/lint
    - name: test
      run: bin/test
steps:
  - run: ${{ matrix.run }}
```

### Exit status

| Status        | Meaning                                                                                                |
| ------------- | ------------------------------------------------------------------------------------------------------ |
| 0             | Every stack that ran passed, or the script didn't apply                                                |
| 2             | A usage error (an unknown argument, a path or flag with no stack); nothing ran                         |
| anything else | A runner failed (with several stacks, the last failing one's status), or `bin/ci` found nothing to run |

## Testing the scripts

```sh
templates/shared/test/run [name-filter]
```

The runner builds throwaway Ruby-only, TS-only and mixed repos under `$TMPDIR`, puts stub `bundle` and `pnpm` executables first on `PATH` that record every command line, runs the scripts, and checks the recorded commands and exit statuses. It needs only bash. It also runs `shellcheck` over the scripts when it's installed.
