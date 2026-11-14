# rubocop-bottrall

The shared Ruby style for bottrall projects, as a [RuboCop](https://rubocop.org) plugin. One gem brings:

- `config/base.yml`: the shared style (new cops enabled, one-argument-per-line layout, `Metrics` off except `Metrics/BlockNesting`, compact class nesting, `extend_self` modules, one assertion per Minitest test), with [rubocop-minitest](https://github.com/rubocop/rubocop-minitest), [rubocop-performance](https://github.com/rubocop/rubocop-performance) and [rubocop-rake](https://github.com/rubocop/rubocop-rake) as dependencies and plugins.
- `config/rbs-inline.yml`: lets `Layout/LeadingCommentSpace` and `Layout/LineLength` accept [rbs-inline](https://github.com/soutaro/rbs-inline) annotations.
- Three cops in the `Bottrall/` department:
  - `Bottrall/NoInheritance`: compose instead of inheriting. A superclass is allowed only when it's listed in `AllowedParents`, its name ends in `Error`, or it's a core class that is `Exception` or a `StandardError` descendant.
  - `Bottrall/NoMocking`: no `stub`, no `Minitest::Mock`, and (for code under `OwnedNamespaces`) no methods patched in with `define_singleton_method` / `define_method`. Inject a real lightweight fake instead. Only checks test files (`**/test/**/*`, `**/*_test.rb`).
  - `Bottrall/RequireDisableReason`: every `rubocop:disable` / `rubocop:todo` ends with `-- <reason>`.

Requires RuboCop 1.72 or later (the plugin system) and Ruby 3.3 or later.

## Usage

Add the gem to your `Gemfile`:

```ruby
gem 'rubocop-bottrall', require: false
```

Then point `.rubocop.yml` at it:

```yaml
plugins:
  - rubocop-bottrall

inherit_gem:
  rubocop-bottrall:
    - config/base.yml
    - config/rbs-inline.yml # only if the project writes rbs-inline annotations

inherit_mode:
  merge:
    - Exclude
```

`inherit_mode: merge: [Exclude]` adds your own `AllCops: Exclude` entries to the shared ones (`bin/`, `vendor/`, `sig/`, `pkg/`, `tmp/`, `.claude/`, `node_modules/`) instead of replacing them.

### Configuring the cops

`Bottrall/NoInheritance` allows no parents beyond errors until you list your framework-mandated ones, by fully qualified constant name:

```yaml
Bottrall/NoInheritance:
  AllowedParents:
    - ApplicationRecord
    - ApplicationController
```

For a one-off parent, use a scoped disable with a reason instead: `# rubocop:disable Bottrall/NoInheritance -- <reason>`.

`Bottrall/NoMocking` flags `stub` and `Minitest::Mock` everywhere. To also flag methods patched onto your own code (`MyGem::Client.define_singleton_method(...)`, `MyGem::Client.singleton_class.define_method(...)`, or `define_singleton_method` on a local built from `MyGem::...` in the same test), list the namespaces you own:

```yaml
Bottrall/NoMocking:
  OwnedNamespaces:
    - MyGem
```

## Development

| Command | What it does |
|---|---|
| `bin/setup` | Install dependencies |
| `bin/test [paths] [minitest flags]` | Run the tests |
| `bin/lint [--fix] [paths]` | Lint the gem with its own plugin and `config/base.yml` |
| `bin/build` | Build the gem into `pkg/`, install it into an empty `GEM_HOME`, and check it loads |
| `bin/check` | `bin/lint --fix`, then `bin/test` |
| `bin/ci` | Exactly what CI runs: tests, lint, build |

## Contributing

Bug reports and pull requests are welcome at https://github.com/bottrall/blueprint.

## License

Released under the [MIT License](LICENSE).
