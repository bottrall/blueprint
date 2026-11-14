# {{name}}

{{description}}

{{> agents/commands.md}}

## Layout

- `exe/{{name}}` is the entry point and the one place that wires collaborators together: it loads the bundle and `lib/{{require_path}}.rb`, then calls into `lib/`. Keep it to wiring; behaviour belongs in `lib/`, where it's tested.
- `lib/{{require_path}}.rb` sets up Zeitwerk, which loads everything under `lib/`, so a file's path must match its constant's name (`lib/{{require_path}}/greeting.rb` is `{{module}}::Greeting`). Never `require` a file in `lib/`. Namespaces are compact (`module {{module}}::Greeting`).
- `test/` mirrors `lib/`: `test/{{require_path}}/greeting_test.rb` tests `lib/{{require_path}}/greeting.rb`. Fixtures go in `test/fixtures/<topic>/`.
- `sig/generated/` holds the signatures `bin/generate` writes from `lib/`'s inline annotations, `sig/manual/` the hand-written ones, mirroring `lib/`, and `sig/_private/` stubs for gaps in other gems' signatures.
- The app runs on the Ruby in `.ruby-version` alone: the `Gemfile` requires it, and CI tests on it.

{{> agents/code-style.md}}

{{> agents/testing.md}}

{{> agents/ruby-typing.md}}

{{> agents/comments.md}}
