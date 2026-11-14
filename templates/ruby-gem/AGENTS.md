# {{name}}

{{description}}

{{> agents/commands.md}}

## Layout

- `lib/{{require_path}}.rb` is the entry point: it sets up Zeitwerk, which loads everything under `lib/{{require_path}}/`, so a file's path must match its constant's name (`lib/{{require_path}}/greeting.rb` is `{{module}}::Greeting`). Never `require` a file in `lib/`.
- Namespaces are compact (`module {{module}}::Greeting`), except `lib/{{require_path}}/version.rb`, which the gemspec loads before anything else and the entry point `require_relative`s.
- `test/` mirrors `lib/`: `test/{{require_path}}/greeting_test.rb` tests `lib/{{require_path}}/greeting.rb`. Fixtures go in `test/fixtures/<topic>/`.
- `sig/generated/` holds the signatures `bin/generate` writes from `lib/`'s inline annotations, `sig/manual/` the hand-written ones, mirroring `lib/`, and `sig/_private/` stubs for gaps in other gems' signatures.
- The gemspec ships `lib/`, `sig/`, `README.md`, `CHANGELOG.md` and `LICENSE`. `bin/build` fails when the gem leaves out a file in `lib/` or `sig/`, then installs the built gem into an empty `GEM_HOME` and loads every file.

## Releasing

- release-please keeps a release PR open that bumps `VERSION` in `lib/{{require_path}}/version.rb` and `Gemfile.lock`, and writes the `CHANGELOG.md` section, from the PR titles merged since the last release. Never edit the version or `CHANGELOG.md` by hand.
- Merging the release PR tags the release, and `.github/workflows/release.yml` runs `bin/ci`, then publishes the gem to RubyGems with trusted publishing from the `release` environment.

{{> agents/code-style.md}}

{{> agents/testing.md}}

{{> agents/ruby-typing.md}}

{{> agents/comments.md}}
