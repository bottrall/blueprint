# blueprint

bottrall's project conventions in one place: how code is styled and checked, how a repo is laid out, how everything is run, and how new projects start.

| Part                                  | What it is                                                                                    | How a repo gets it                       |
| ------------------------------------- | --------------------------------------------------------------------------------------------- | ---------------------------------------- |
| [`ruby/`](ruby/README.md)             | `rubocop-bottrall`: the shared RuboCop style and the `Bottrall/` cops                         | A gem, kept current by Renovate          |
| [`typescript/`](typescript/README.md) | `@bottrall/oxlint-config`: shared oxlint configs, the `bottrall/` rules and a `tsconfig` base | An npm package, kept current by Renovate |
| [`templates/`](templates/README.md)   | `ruby-gem`, `ruby-app` and `ts-app`, plus the shared `bin/` scripts and repo files            | Copied once by `templates/instantiate`   |
| [`agents/`](agents/README.md)         | The AGENTS.md sections every repo shares                                                      | Copied into each repo's AGENTS.md        |
| [`tools/`](tools/)                    | Scripts that apply the standard GitHub settings                                               | Run against a repo                       |

[`AGENTS.md`](AGENTS.md) explains how to start a project from blueprint and how to check a repo against it; point Claude at this repo and ask. [`POLICY.md`](POLICY.md) says why each rule exists and what enforces it.

## Contributing

See [CONTRIBUTING.md](CONTRIBUTING.md). Changes to a rule, a template or the shared text follow [Changing blueprint](AGENTS.md#changing-blueprint).

## License

[MIT](LICENSE)
