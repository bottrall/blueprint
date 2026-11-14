# blueprint

The single source of bottrall's project conventions: the `rubocop-bottrall` gem (`ruby/`), the `@bottrall/oxlint-config` npm package (`typescript/`), the project templates (`templates/`) and the shared AGENTS.md text (`agents/`). [`POLICY.md`](POLICY.md) says why each rule exists. This file says how to start a new project from blueprint, how to check an existing repo against it, and how to change blueprint itself. The shared rules in [`agents/`](agents/README.md) (code style, testing, comments, Ruby typing) apply to this repo's own code too.

## Commands

Everything runs through `bin/`, never a tool directly. Each package also has its own `bin/` with the same names, run from inside `ruby/` or `typescript/`.

| Script                  | Does                                                                                |
| ----------------------- | ----------------------------------------------------------------------------------- |
| `bin/setup`             | installs both packages' dependencies                                                |
| `bin/test`              | runs both packages' tests, then the template tests                                  |
| `bin/lint [--fix]`      | checks lint and formatting in both packages; `--fix` fixes what it can              |
| `bin/build`             | builds and verifies both packages                                                   |
| `bin/check`             | fixes lint, then tests, in both packages: run it before calling a change done       |
| `bin/ci`                | runs what CI runs, without fixing anything, plus shellcheck: run it before you push |
| `templates/instantiate` | creates a project from a template (below)                                           |
| `tools/repo-settings`   | applies the standard GitHub settings to a repo                                      |
| `tools/require-checks`  | adds required status checks to a repo's ruleset                                     |

## Starting a new project

1. **Settle the inputs** with the user if they haven't given them: the template, the name, a one-sentence description, and public or private.
   - `ruby-gem`: a published Ruby gem.
   - `ruby-app`: a Ruby CLI or service that isn't published. A Skyward web app starts with `skyward new` instead.
   - `ts-app`: a Preact web app.
2. **Create it**: `templates/instantiate <template> ../<name> name=<name> description='<description>'`, plus `module=` and `require_path=` for the Ruby templates (e.g. `module=Sample::Gem require_path=sample/gem`). [`templates/README.md`](templates/README.md) lists each template's placeholders. The script refuses a non-empty target and any placeholder left unfilled.
3. **Make it pass** in the new directory: `git init -b main`, `bin/setup`, `bin/lint --fix` (in a TS project this realigns the `bin/` tables the template trimmed), then `bin/ci`, which must pass before anything is pushed.
4. **Publish the repo**: commit (`chore: start <name> from bottrall/blueprint`), then `gh repo create bottrall/<name> --<public|private> --source . --push`. This first push to `main` is the one commit that doesn't go through a PR.
5. **Apply the settings**: `tools/repo-settings bottrall/<name>`. Then open the first change as a PR; once its CI has run, require its checks by the names CI shows: `tools/require-checks bottrall/<name> <check> ... pr-title` (public repos only; private repos on the Free plan have no rulesets).
6. **Onboard onto deps**: append `bottrall/<name>` to the `RENOVATE_REPOSITORIES` variable on `bottrall/deps` (`gh variable get` / `gh variable set`). The deps App is installed on every repo. Its two secrets can't be set from here: ask the user to run, on their MacBook,
   ```sh
   gh secret set DEPS_APP_CLIENT_ID --repo bottrall/<name> --body "$(jq -r .client_id ~/.config/bottrall-deps/app.json)"
   gh secret set DEPS_APP_PRIVATE_KEY --repo bottrall/<name> < ~/.config/bottrall-deps/app.pem
   ```
7. **Releases** (`ruby-gem` only): the first release can publish only once the user adds a pending trusted publisher on RubyGems.org for the gem (repository `bottrall/<name>`, workflow `release.yml`, environment `release`). Ask them to, and don't merge the first release PR before they confirm.

## Checking an existing repo

Report drift; change nothing unless the user asks, and then fix it through PRs.

1. **Instantiate its template** into a scratch directory with the repo's own values, and compare:
   - Byte-for-byte: `bin/` and `bin/lib/` (only the scripts the repo uses), `.shellcheckrc`, `.github/workflows/pr-title.yml`, `.github/workflows/deps.yml`, `renovate.json`, `.github/pull_request_template.md`, `CODE_OF_CONDUCT.md`, `SECURITY.md`.
   - By intent: `ci.yml` (named `ci`; every check runs a `bin/*` script), the Rakefile's task names, `.rubocop.yml`, `.oxlintrc.json`, `.oxfmtrc.json`, `tsconfig.json`, the gemspec or `package.json` (no `scripts` block), `.gitignore`, `.gitattributes`.
2. **Packages**: the repo uses `rubocop-bottrall` (with `config/base.yml`, plus `config/rbs-inline.yml` where it uses rbs-inline) or `@bottrall/oxlint-config`, at the latest release, and keeps no local copies of their cops or rules.
3. **AGENTS.md**: it carries `agents/*.md` verbatim where they apply, keeps its repo-specific rules, and its commands table lists exactly its `bin/` scripts. There's no `CLAUDE.md` or `.claude/` directory.
4. **Settings**: compare `gh api repos/<repo>`, its Actions workflow permissions, its `release` environment and its ruleset with what `tools/repo-settings` applies; the ruleset requires every CI check plus `pr-title`.
5. **Report** the drift as a list, worst first: what differs, why it matters, and the fix.

## Changing blueprint

- **A rule** (a cop, an oxlint rule, a config setting): change the package, `POLICY.md`, and any `agents/` text that states it, in one PR with a `feat:` or `fix:` title. release-please opens a release PR per package; merging it publishes. Repos then get the new version through deps' "linters and formatters" PR, where a rule that breaks their CI stops for review.
- **A template or a shared `bin/` script**: existing repos don't pick the change up by themselves. Check the repos it affects (above) and move them over with PRs. Keep the shared scripts byte-identical across repos, compatible with bash 3.2 (macOS), covered by `templates/shared/test/`, and shellcheck-clean.
- **Shared AGENTS.md text** (`agents/`): the same; repos carry it verbatim, so a change means a PR to each repo that includes it.
- **Release PRs** are opened by GitHub Actions, which doesn't trigger CI on them. Close and reopen one to run its checks before merging.
