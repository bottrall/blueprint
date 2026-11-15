# blueprint

The single source of bottrall's project conventions: the `rubocop-bottrall` gem (`ruby/`), the `@bottrall/oxlint-config` npm package (`typescript/`), the starter files (`templates/`) and the shared AGENTS.md text (`agents/`). [`SETUP.md`](SETUP.md) says how to set up a project, or check an existing one, the way the user wants it. [`POLICY.md`](POLICY.md) says why each rule exists. This file covers working on blueprint itself. The shared rules in [`agents/`](agents/README.md) (code style, testing, comments, Ruby typing) apply to this repo's own code too.

## Commands

Everything runs through `bin/`, never a tool directly. Each package also has its own `bin/` with the same names, run from inside `ruby/` or `typescript/`.

| Script             | Does                                                                                |
| ------------------ | ----------------------------------------------------------------------------------- |
| `bin/setup`        | installs both packages' dependencies                                                |
| `bin/test`         | runs both packages' tests, then the starter `bin/` script tests                     |
| `bin/lint [--fix]` | checks lint and formatting in both packages; `--fix` fixes what it can              |
| `bin/build`        | builds and verifies both packages                                                   |
| `bin/check`        | fixes lint, then tests, in both packages: run it before calling a change done       |
| `bin/ci`           | runs what CI runs, without fixing anything, plus shellcheck: run it before you push |

## Setting up or checking a project

Follow [`SETUP.md`](SETUP.md). It lists the technologies, the starter files to copy from `templates/`, the GitHub settings, onboarding onto deps, releases, and what to compare when checking an existing repo.

## Changing blueprint

- **A rule** (a cop, an oxlint rule, a config setting): change the package, `POLICY.md`, and any `agents/` text that states it, in one PR with a `feat:` or `fix:` title. release-please opens a release PR per package; merging it publishes. Repos then get the new version through deps' "linters and formatters" PR, where a rule that breaks their CI stops for review.
- **A starter file or a shared `bin/` script**: existing repos don't pick the change up by themselves. Copy it into the repos it affects with PRs. Keep the shared scripts byte-identical across repos, compatible with bash 3.2 (macOS), covered by `test/bin-scripts/`, and shellcheck-clean.
- **Shared AGENTS.md text** (`agents/`): the same. Repos carry it verbatim, so a change means a PR to each repo.
- **Release PRs** are opened by GitHub Actions, which doesn't trigger CI on them. Close and reopen one to run its checks before merging.
