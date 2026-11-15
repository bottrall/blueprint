# Setting up a project

How to set up a bottrall project, or bring an existing one in line: the technologies to use, the starter files to copy from [`templates/`](templates/), and everything outside the code (GitHub settings, Renovate, releases). There's no generator. Copy the files, edit them for the project, and follow the steps here.

## Technologies

### Every repo

- **GitHub**, under `bottrall`, with **GitHub Actions** for CI and releases. Third-party Actions are pinned to commit hashes, with the version in a comment, and Renovate keeps them current; `bottrall/deps`'s fix workflow stays on `@main`.
- **`bin/` scripts** for every task (setup, test, lint, typecheck, build, …). People, CI and agents run the same commands, so a local pass means a CI pass.
- **Conventional Commits** PR titles, squash-merged, so each title becomes the commit on `main`.
- **release-please** for anything that publishes: it turns those titles into the version bump and changelog. Publishing uses the registry's **trusted publishing**, so no API key is stored anywhere.
- **Renovate**, configured centrally in `bottrall/deps`, for weekly dependency updates.
- **AGENTS.md** for the conventions, built from the shared sections in [`agents/`](agents/README.md). No `CLAUDE.md` and no `.claude/` directory.
- **MIT** license.

### Ruby

- **Ruby**, pinned in `.ruby-version`.
- **Bundler**, with the lockfile committed.
- **Zeitwerk** for loading. A file's path matches its constant's name, and nothing in `lib/` is `require`d.
- **Minitest**, with the spec DSL (`describe` / `it`).
- **RuboCop** through [`rubocop-bottrall`](ruby/README.md), the shared style plus the `Bottrall/` cops.
- **Steep** with every diagnostic as an error, over **rbs-inline** annotations (`--opt-out`, so every file is annotated). Signatures live in `sig/generated` (written by `bin/generate`), `sig/manual` (hand-written, mirroring `lib/`) and `sig/_private` (stubs for other gems' gaps, never shipped).
- **gem_rbs_collection**, pinned to one revision in `rbs_collection.yaml`, for other gems' signatures.
- **Guard** to regenerate signatures on save (`bin/generate --watch`).
- **Rake** for the tasks behind `bin/`.

### TypeScript

- **Node**, pinned in `.nvmrc`. **pnpm** through corepack, pinned by `packageManager`. `pnpm-workspace.yaml` exempts bottrall's own packages (`@bottrall/*`) from pnpm's minimum release age, so a fresh release of one can be used at once; everything else waits.
- `package.json` has **no `scripts`**: `bin/` is the interface.
- **TypeScript**, strict, extending the shared `tsconfig` from [`@bottrall/oxlint-config`](typescript/README.md).
- **oxlint** and **oxfmt** through `@bottrall/oxlint-config`.
- **Vitest** with coverage enforced per file (the thresholds are in the starter [`vitest.config.ts`](templates/typescript/vitest.config.ts)), and **Testing Library**. Tests sit beside the source as `*.test.ts(x)`.
- **Playwright** for end-to-end tests, run against the production build.
- **Vite** for builds and the dev server, and **mprocs** when `bin/dev` runs more than one process.
- **Preact** (not React), **@preact/signals** for state, **preact-iso** for routing, **Tailwind** with design tokens in `@theme`, and **valibot** to parse anything from outside.

## Starter files

| Folder                                           | For              | What's in it                                                                         |
| ------------------------------------------------ | ---------------- | ------------------------------------------------------------------------------------ |
| [`templates/common/`](templates/common/)         | every repo       | The `bin/` scripts, the shared workflows, the Renovate config and the repo docs      |
| [`templates/ruby/`](templates/ruby/)             | Ruby repos       | The CI and release workflows, release-please, and the Bundler, lint and type configs |
| [`templates/typescript/`](templates/typescript/) | TypeScript repos | The CI workflow, `package.json`, and the lint, format, build and test configs        |

Copy `common/` and the stack's folder into the new repo. A private repo leaves out `CODE_OF_CONDUCT.md` and `SECURITY.md` until it goes public. Then:

- **Fill in the placeholders**, then check none are left (`grep -rn '{{[a-z_]*}}' .`):
  - `{{name}}`: the project's name, e.g. `riffer-rig`;
  - `{{module}}`: the Ruby constant, e.g. `Riffer::Rig`;
  - `{{require_path}}`: the entry point under `lib/`, e.g. `riffer/rig`;
  - `{{description}}`: one sentence, with no single quotes, since the gemspec quotes it;
  - `{{year}}`: the year, for `LICENSE`.

  GitHub Actions expressions (`${{ … }}`) aren't placeholders.

- **Delete what the project doesn't use:** starter files, and `bin/` scripts with their rows in `CONTRIBUTING.md`. Each script's opening comment says what it runs.
- **Rename** `gem.gemspec` to `<name>.gemspec` if the project keeps it.
- **Make the scripts executable** (`chmod +x bin/*`).

### Ruby layout

- **Entry point.** `lib/<require_path>.rb` sets up Zeitwerk and defines the top-level module.
- **Version.** A project that releases keeps its version in the `VERSION` constant in `lib/<require_path>/version.rb`, which release-please bumps.
- **Tests.** `test/` mirrors `lib/`, and fixtures go in `test/fixtures/<topic>/`.
- **Signatures.** Create `sig/generated/`, `sig/manual/` and `sig/_private/`, each with a `.keep` until it has files.

### TypeScript layout

- **`index.html`** loads `src/main.tsx`.
- **`src/main.tsx`** is the composition root. It's the only file that touches browser globals or builds real collaborators.
- **`src/app.tsx`** holds the shell and the preact-iso routes.
- **`src/styles.css`** holds Tailwind, with the design tokens in `@theme` and their dark values under `prefers-color-scheme: dark`.
- **`src/lib/`** holds code that knows nothing about the project.
- **`src/modules/<feature>/`** holds one flat folder per feature, imported from outside only through its `index.ts`.
- **Imports** carry their `.ts` / `.tsx` extension and use `~/` for `src/`.

## AGENTS.md and README.md

Assemble `AGENTS.md` in this order, so every repo's reads the same way:

1. `# <name>`, then the one-sentence description.
2. [`agents/commands.md`](agents/commands.md), with the rows for `bin/` scripts the repo doesn't have deleted.
3. `## Layout`, specific to the repo: where things go, as in the layout sections above. Then the repo's own rules, such as `## Releasing` when it publishes (release-please opens the release PR; never edit the version or `CHANGELOG.md` by hand).
4. Verbatim, each heading included: [`agents/code-style.md`](agents/code-style.md), [`agents/testing.md`](agents/testing.md), [`agents/ruby-typing.md`](agents/ruby-typing.md) (Ruby repos only), then [`agents/comments.md`](agents/comments.md).

A repo's own rules go in its own sections, never inside a shared one.

`README.md` holds:

- the name and description;
- how to install or run it, and how to use it;
- in a public repo, `## Contributing` (pointing to `CONTRIBUTING.md`) and `## License` at the end.

## Creating the repo

1. **Settle the inputs.** Agree the name, the description, the stack, and public or private with the user.
2. **Make it pass locally.** In the new directory, run `git init -b main`, `bin/setup`, `bin/lint --fix`, then `bin/ci`. `bin/ci` must pass before anything is pushed.
3. **Make the first commit.** Commit with the message `chore: start <name>`.
4. **Create the repo.** Run `gh repo create bottrall/<name> --public|--private --source . --push`. This first push is the only commit to `main` that doesn't go through a PR.

## GitHub settings

Apply these to every repo. Each is a `gh api` call.

### Merging

Squash only, auto-merge on, branches deleted after merge, "update branch" offered, no wiki:

```sh
gh api -X PATCH repos/bottrall/<name> \
  -F allow_squash_merge=true -F allow_merge_commit=false -F allow_rebase_merge=false \
  -F allow_auto_merge=true -F delete_branch_on_merge=true -F allow_update_branch=true \
  -F has_wiki=false
```

### Actions

Workflows get a read-only token by default, and may open PRs (release-please needs this):

```sh
echo '{"default_workflow_permissions":"read","can_approve_pull_request_reviews":true}' |
  gh api -X PUT repos/bottrall/<name>/actions/permissions/workflow --input -
```

### Release environment

Only for repos that publish, meaning any workflow with `environment: release`. Create a `release` environment that only `main` can deploy to:

```sh
echo '{"deployment_branch_policy":{"protected_branches":false,"custom_branch_policies":true}}' |
  gh api -X PUT repos/bottrall/<name>/environments/release --input -
gh api -X POST repos/bottrall/<name>/environments/release/deployment-branch-policies -f name=main -f type=branch
```

### Ruleset

Public repos only: GitHub Free has no rulesets on private repos, and ignores auto-merge there. Create a ruleset named `main` on the default branch that:

- blocks deletion and force-pushes;
- requires a PR, squash-merged, with no required approvals;
- sets `require_extra_approval_for_unattributed_changes` to `false`.

```sh
gh api -X POST repos/bottrall/<name>/rulesets --input - <<'JSON'
{
  "name": "main",
  "target": "branch",
  "enforcement": "active",
  "conditions": { "ref_name": { "include": ["~DEFAULT_BRANCH"], "exclude": [] } },
  "rules": [
    { "type": "deletion" },
    { "type": "non_fast_forward" },
    {
      "type": "pull_request",
      "parameters": {
        "allowed_merge_methods": ["squash"],
        "dismiss_stale_reviews_on_push": false,
        "require_code_owner_review": false,
        "require_last_push_approval": false,
        "required_approving_review_count": 0,
        "required_review_thread_resolution": false,
        "require_extra_approval_for_unattributed_changes": false
      }
    }
  ]
}
JSON
```

### Required checks

Once the first PR's CI has run, require every check CI shows (`gh pr checks <n>`) plus `pr-title`. Add a rule to the ruleset with one `context` per check name: fetch the ruleset (`gh api repos/bottrall/<name>/rulesets/<id>`), add the rule below to its `rules`, and `PUT` it back. Whenever CI gains or renames a job, update the list.

```json
{
  "type": "required_status_checks",
  "parameters": {
    "strict_required_status_checks_policy": false,
    "do_not_enforce_on_create": false,
    "required_status_checks": [
      { "context": "lint" },
      { "context": "typecheck" },
      { "context": "pr-title" }
    ]
  }
}
```

## Dependencies

`renovate.json` extends `github>bottrall/deps`, which holds the whole Renovate setup. To onboard a repo:

1. Append `bottrall/<name>` to the `RENOVATE_REPOSITORIES` variable on `bottrall/deps` (`gh variable get` / `gh variable set`).
2. The deps app is installed on every repo, but its two secrets can't be set from here. Ask the user to run these on their MacBook:

   ```sh
   gh secret set DEPS_APP_CLIENT_ID --repo bottrall/<name> --body "$(jq -r .client_id ~/.config/bottrall-deps/app.json)"
   gh secret set DEPS_APP_PRIVATE_KEY --repo bottrall/<name> < ~/.config/bottrall-deps/app.pem
   ```

## Releases

A project that publishes releases through release-please and `release.yml`:

- **Release PR.** Every push to `main` updates the release PR.
- **Publishing.** Merging the release PR tags the release. `release.yml` then builds it in an unprivileged job and publishes that exact file from the `release` environment. It doesn't re-run CI: the release PR's checks already passed.
- **Lockfile.** A `lockfile` job runs `bundle lock` on the release PR, since release-please doesn't update the lockfile's checksums.
- **Trusted publisher.** Before the first release PR is merged, the user adds a pending trusted publisher on the registry it publishes to: repository `bottrall/<name>`, workflow `release.yml`, environment `release`. Ask them to, and wait for confirmation.
- **Don't rename.** A trusted publisher is tied to the workflow's file name and the environment, so renaming either stops publishing.
- **CI on release PRs.** GitHub Actions opens the release PRs, which doesn't trigger CI. Close and reopen one to run its checks before merging.

## Checking an existing repo

Report what differs from this file, worst first, and fix it through PRs only when the user asks.

1. **Shared files.** Everything in `templates/common/` matches byte for byte, after placeholders, for the scripts and files the repo uses.
2. **Stack files.** These follow the stack's starter files in intent, not to the letter:
   - CI runs only `bin/*` scripts;
   - the release flow builds in an unprivileged job, publishes that file from `release`, and doesn't re-run CI;
   - the Rakefile's task names match;
   - `package.json` has no `scripts`.
3. **Shared configs.** The repo uses `rubocop-bottrall` or `@bottrall/oxlint-config` at the latest release, with no local copies of their cops or rules.
4. **AGENTS.md.** It's assembled as above, with the shared sections verbatim.
5. **Settings.** They match [GitHub settings](#github-settings).
