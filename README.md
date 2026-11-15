# blueprint

bottrall's project conventions in one place: how code is styled and checked, how a repo is laid out, how everything is run, and how a project is set up.

| Part                                  | What it is                                                                                    | How a repo gets it                       |
| ------------------------------------- | --------------------------------------------------------------------------------------------- | ---------------------------------------- |
| [`ruby/`](ruby/README.md)             | `rubocop-bottrall`: the shared RuboCop style and the `Bottrall/` cops                         | A gem, kept current by Renovate          |
| [`typescript/`](typescript/README.md) | `@bottrall/oxlint-config`: shared oxlint configs, the `bottrall/` rules and a `tsconfig` base | An npm package, kept current by Renovate |
| [`templates/`](templates/)            | Starter files: the shared `bin/` scripts, CI and release workflows, tool configs, repo docs   | Copied, then edited for the project      |
| [`agents/`](agents/README.md)         | The AGENTS.md sections every repo shares                                                      | Copied into each repo's AGENTS.md        |

[`SETUP.md`](SETUP.md) explains how to set up a project and check an existing one: technologies, starter files, GitHub settings, deps and releases. Point Claude at this repo and ask.

## Contributing

See [CONTRIBUTING.md](CONTRIBUTING.md). Changes to a rule, a starter file or the shared text follow [Changing blueprint](AGENTS.md#changing-blueprint).

## License

[MIT](LICENSE)
