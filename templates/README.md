# Templates

The starting files for a new repo. Every project is [`shared/`](shared/README.md), the `bin/` scripts, workflows and repo docs every repo gets, with one stack template copied over it:

| Template              | For                                                                                                                            |
| --------------------- | ------------------------------------------------------------------------------------------------------------------------------ |
| [`shared/`](shared/README.md) | Every repo: the stack-aware `bin/` scripts, `pr-title.yml` and `deps.yml`, `renovate.json`, `LICENSE`, `CONTRIBUTING.md`, `CODE_OF_CONDUCT.md`, `SECURITY.md`. Never used on its own |
| `ruby-gem/`           | A gem published to RubyGems: Zeitwerk, Minitest, RuboCop through `rubocop-bottrall`, Steep over rbs-inline, CI on every Ruby that isn't end-of-life, and release-please publishing with RubyGems trusted publishing |
| `ruby-app/`           | A Ruby application that isn't a gem, such as a command-line tool or a service: the same tooling, an `exe/` entry point, the Ruby in `.ruby-version` alone, and no releases. For a Skyward web app, run `skyward new` instead |

## Creating a project

```sh
templates/instantiate <template> <target-dir> key=value...
```

For example:

```sh
templates/instantiate ruby-gem ../sample-gem \
  name=sample-gem module=SampleGem require_path=sample_gem \
  description='A sample gem made from the ruby-gem template.'
cd ../sample-gem
git init
bin/setup
bin/ci
```

The script needs only Ruby's standard library. It assembles the project as [`shared/README.md`](shared/README.md#assembling-a-project) describes: it copies `shared/` and then the template over it, leaving out each `template.json`'s `exclude` paths, deletes the template's `remove` paths and their rows in the `bin/` tables of `CONTRIBUTING.md` and `AGENTS.md`, substitutes the placeholders in every file and path, expands each `{{> agents/<file>.md}}` line from [`agents/`](../agents/README.md), and makes the `executable` paths executable.

It writes nothing when:

- the target directory exists and isn't empty;
- a placeholder the templates declare wasn't given, or a `key=` isn't one of them;
- anything still reads `{{...}}` once it's done, in a file or a path, such as a placeholder no `template.json` declares or an include of a file `agents/` doesn't have. GitHub Actions expressions, `${{ ... }}`, are left alone.

Run it with no arguments to list the templates.

### Placeholders

Each template's `template.json` lists the placeholders it uses. The Ruby templates take:

| Placeholder    | Example                     | Used for                                                       |
| -------------- | --------------------------- | -------------------------------------------------------------- |
| `name`         | `sample-gem`                | The repo, the gem or the app's executable                      |
| `module`       | `SampleGem`                 | The Ruby constant everything in `lib/` lives under             |
| `require_path` | `sample_gem`                | `lib/<require_path>.rb`, the entry point                       |
| `description`  | `Says hello.`               | One sentence for the README, `AGENTS.md` and the gemspec summary; no single quotes, since the gemspec quotes it |
| `year`         | `2026`                      | `LICENSE`; defaults to this year                               |

The Ruby templates expect a `module` that is a single constant. A gem that extends another gem's namespace (`riffer-rig`, `Riffer::Rig`, `riffer/rig`) needs its entry point and `version.rb` adapted afterwards, as the comment in `lib/<require_path>.rb` explains.

### After creating a project

- Commit everything `bin/setup` wrote along with the template's files, `Gemfile.lock` included.
- In a gem's repo, before merging the first release PR, create the `release` environment, restricted to `main`, and add a pending trusted publisher for the gem on RubyGems.org naming the repo, `release.yml` and the `release` environment. `release.yml` names the owning account in its token exchange, which is what lets trusted publishing create a gem that doesn't exist yet.
- Delete the sample `Greeting` module, its test and its signatures once there's real code to check.

## Testing the instantiate script

```sh
templates/test/run [minitest flags]
```

It instantiates small fixture templates under `$TMPDIR` to check each rule above, then instantiates every real template here to check none leaves a placeholder behind. It needs only Ruby. The `bin/` scripts have their own tests, in [`shared/test/`](shared/README.md#testing-the-scripts).
