# {{name}}

{{description}}

## Development

You need the Node in `.nvmrc` (`nvm use`) and pnpm through `corepack enable`. Then:

```sh
bin/setup                              # install dependencies
pnpm exec playwright install chromium  # once, for bin/e2e
bin/dev                                # http://localhost:5173
```

Everything else runs through `bin/` too; [CONTRIBUTING.md](CONTRIBUTING.md) lists the scripts.

## Contributing

Bug reports and pull requests are welcome on [GitHub](https://github.com/bottrall/{{name}}). See [CONTRIBUTING.md](CONTRIBUTING.md) for setup and workflow. Everyone interacting in the project is expected to follow the [code of conduct](CODE_OF_CONDUCT.md).

## License

Released under the [MIT License](LICENSE).
