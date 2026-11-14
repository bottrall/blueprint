# @bottrall/oxlint-config

Shared [oxlint](https://oxc.rs/docs/guide/usage/linter) configs, custom oxlint rules and a shared `tsconfig` for bottrall's JavaScript and TypeScript projects.

| Export              | What it is                                                                                                                                                                       |
| ------------------- | -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `oxlint/base.json`  | What every JS/TS repo gets: every category at `error`, unused disable directives reported, the core, unicorn and TypeScript rule settings, and the universal `bottrall/*` rules. |
| `oxlint/app.json`   | `base.json` plus what a Preact + Tailwind app gets: React rules, the Tailwind rules, and the vitest / Testing Library / jest-dom rules for `*.test.ts(x)` files.                 |
| `plugin`            | The oxlint JS plugin (`bottrall`) that defines the custom rules below. Both configs load it for you.                                                                             |
| `tsconfig/app.json` | Shared `compilerOptions` for a Preact app (strict, `noUncheckedIndexedAccess`, `verbatimModuleSyntax`, bundler resolution, Preact JSX).                                          |

## A plain JS/TS repo

```sh
pnpm add -D @bottrall/oxlint-config oxlint oxfmt
```

`.oxlintrc.json`:

```json
{
  "$schema": "./node_modules/oxlint/configuration_schema.json",
  "extends": ["./node_modules/@bottrall/oxlint-config/oxlint/base.json"],
  "plugins": [],
  "ignorePatterns": ["node_modules/**"]
}
```

`"plugins": []` matters: without it oxlint adds its default plugins (including `oxc`) on top of the shared ones. `ignorePatterns` is yours because `extends` does not carry it (see [What `extends` carries](#what-extends-carries)).

`.oxfmtrc.json` (oxfmt has no `extends`, so this is copied, not shared):

```json
{
  "$schema": "./node_modules/oxfmt/configuration_schema.json",
  "ignorePatterns": ["node_modules/**", "pnpm-lock.yaml"],
  "sortImports": { "sortSideEffects": true }
}
```

## A Preact app

```sh
pnpm add -D @bottrall/oxlint-config oxlint oxfmt \
  eslint-plugin-better-tailwindcss eslint-plugin-testing-library eslint-plugin-jest-dom
```

The three `eslint-plugin-*` packages are optional peer dependencies: `app.json` loads them, `base.json` does not, so plain repos never install them.

`.oxlintrc.json` — two values are yours to set: the Tailwind `entryPoint` (the stylesheet that imports Tailwind) and the override's `files` (your source files, not configs, scripts or e2e specs):

```json
{
  "$schema": "./node_modules/oxlint/configuration_schema.json",
  "extends": ["./node_modules/@bottrall/oxlint-config/oxlint/app.json"],
  "plugins": [],
  "settings": {
    "better-tailwindcss": { "entryPoint": "./src/styles.css" }
  },
  "overrides": [
    {
      "files": ["src/**/*.{ts,tsx}"],
      "rules": {
        "bottrall/no-default-export": "error",
        "bottrall/require-colocated-test": "error"
      }
    }
  ],
  "ignorePatterns": ["node_modules/**", "dist/**", "coverage/**"]
}
```

- `"plugins": []` and `ignorePatterns` are there for the same reasons as in a plain repo.
- `settings` is required for the Tailwind rules: without `entryPoint`, `better-tailwindcss` cannot see your theme and reports `No tailwind css entry point found`. Only `entryPoint` goes here; the class selectors (`class`, `className`, `cx()`, and variables named like `buttonClasses`) are already set in `app.json`'s rule options, so name your class-joining helper `cx`.
- The `overrides` entry is where the source-only rules live, because only you know where your source is. Add more globs to `files` (for example `"world/**/*.ts"`) or more entries for project-specific rules such as `no-restricted-imports` boundaries. A `require-colocated-test` entry point with no test of its own can be skipped with `["error", { "exempt": ["src/main.tsx"] }]`.
- The unit-test rules are already scoped to `**/*.test.{ts,tsx}`. Name Playwright specs `*.spec.ts` (Playwright's default) so they stay out of that block.
- `app.json` turns away `react` and `react-dom` imports with `no-restricted-imports`. If you set `no-restricted-imports` yourself for some files, your options replace these for those files, so repeat the two `paths` entries.

`.oxfmtrc.json` — oxfmt sorts Tailwind classes in `class`, `className` and `cx()` calls, which is why `app.json` only enforces class order on class-named variables:

```json
{
  "$schema": "./node_modules/oxfmt/configuration_schema.json",
  "ignorePatterns": ["node_modules/**", "dist/**", "coverage/**", "pnpm-lock.yaml"],
  "sortImports": { "sortSideEffects": true },
  "sortTailwindcss": {
    "stylesheet": "./src/styles.css",
    "functions": ["cx"],
    "preserveWhitespace": true
  }
}
```

`tsconfig.json` — keep `paths`, `include` and `types` in your own file:

```json
{
  "extends": "@bottrall/oxlint-config/tsconfig/app.json",
  "compilerOptions": {
    "types": ["node", "vite/client"],
    "paths": { "~/*": ["./src/*"] }
  },
  "include": ["src", "e2e", "vite.config.ts"]
}
```

## What `extends` carries

Checked against oxlint 1.93.0 with this package installed into a consumer's `node_modules`:

| Key in a shared config                                      | Reaches the consumer?                                                                                                                                          |
| ----------------------------------------------------------- | -------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `rules`, `categories`, `options`                            | Yes.                                                                                                                                                           |
| `plugins`                                                   | Yes, merged with the consumer's. If the consumer leaves `plugins` out, oxlint also adds its defaults (`unicorn`, `typescript`, `oxc`), so set `"plugins": []`. |
| `jsPlugins`                                                 | Yes. Paths and package names resolve relative to the shared config file, so the consumer never repeats them.                                                   |
| `overrides` (with their `plugins`, `jsPlugins` and `rules`) | Yes, and their `files` globs match paths relative to the consumer's project. A consumer's own overrides can use `bottrall/*` rules without listing the plugin. |
| `extends` inside a shared config                            | Yes (`app.json` extends `base.json`).                                                                                                                          |
| `settings`                                                  | No — the consumer must set them.                                                                                                                               |
| `ignorePatterns`                                            | No — the consumer must set them.                                                                                                                               |

`extends` takes file paths only, not package specifiers, hence `./node_modules/@bottrall/oxlint-config/...`.

## Rules

| Rule                                   | In                        | Reports                                                                                                                                       |
| -------------------------------------- | ------------------------- | --------------------------------------------------------------------------------------------------------------------------------------------- |
| `bottrall/no-inheritance`              | base                      | `extends` on a class, except for subclasses of an `…Error`.                                                                                   |
| `bottrall/no-explicit-return-types`    | base                      | Function return type annotations, except type predicates and assertion signatures.                                                            |
| `bottrall/no-type-casts`               | base                      | `as T` and `<T>x` casts, except `as const`.                                                                                                   |
| `bottrall/no-screaming-case`           | base                      | `SCREAMING_CASE` variable names (not in `.d.ts` files).                                                                                       |
| `bottrall/require-disable-description` | base                      | `eslint-disable` / `oxlint-disable` directives without a ` -- <reason>`.                                                                      |
| `bottrall/no-mocking`                  | app, unit tests           | `vi.mock`, `vi.doMock` and `vi.spyOn`.                                                                                                        |
| `bottrall/no-unlintable-classes`       | app                       | `class` / `className` values and `cx()` arguments that the Tailwind rules cannot see.                                                         |
| `bottrall/no-default-export`           | app, your source override | `export default`.                                                                                                                             |
| `bottrall/require-colocated-test`      | app, your source override | A module that exports a function, component or class with no sibling `*.test.*` / `*.spec.*` file. Option: `{ "exempt": ["<path suffix>"] }`. |

To use a rule outside these configs, load the plugin yourself with `"jsPlugins": ["./node_modules/@bottrall/oxlint-config/plugin/index.js"]`.

## Contributing

Everything runs through `bin/`, from this directory:

| Command                    | What it does                                                                                            |
| -------------------------- | ------------------------------------------------------------------------------------------------------- |
| `bin/setup`                | Install dependencies.                                                                                   |
| `bin/test [paths]`         | Run the tests with `node --test`; they drive the real oxlint CLI over the fixtures in `test/fixtures/`. |
| `bin/lint [--fix] [paths]` | oxlint with this package's own `base.json`, and `oxfmt --check` (`--fix` fixes both).                   |
| `bin/build`                | `pnpm pack` into a temp dir and check the tarball's contents.                                           |
| `bin/check`                | `bin/lint --fix`, then `bin/test`.                                                                      |
| `bin/ci`                   | What CI runs: `bin/lint`, `bin/test`, `bin/build`.                                                      |

A rule's tests are a fixture directory, `test/fixtures/rules/<rule>/`: files named `invalid*` mark each line the rule must report with `✗`, and every other file must not be reported at all.

## License

[MIT](LICENSE)
