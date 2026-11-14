# {{name}}

{{description}} A static Preact app, built with Vite and styled with Tailwind.

{{> agents/commands.md}}

## Layout

- `index.html`: the page Vite serves and builds; it loads `src/main.tsx`.
- `src/main.tsx`: the composition root. The only file that touches browser globals (`document`, `localStorage`, `fetch`) and constructs the real collaborators the app is handed.
- `src/app.tsx`: the shell, its navigation and its routes.
- `src/styles.css`: Tailwind and the design tokens in `@theme`, with their dark values under `prefers-color-scheme: dark`.
- `src/lib/`: code that knows nothing about this app.
- `src/modules/<feature>/`: one flat folder per feature, its logic and components together. Code outside the folder imports it only through its `index.ts`.
- `test/setup.ts`: vitest setup (jest-dom matchers, cleanup after each test).
- `e2e/`: Playwright specs (`*.spec.ts`), run against a production build served by `vite preview`.

## App conventions

- **Preact, not React.** Import from `preact`, `preact/hooks` and `preact-iso`; write `class`, not `className`.
- **State is signals.** A component's own state is a `useSignal` (or `useComputed`) that it reads and writes through `.value`; there's no `useState`. State a feature shares lives in `signal`s owned by a plain `.ts` factory that also makes every write to them; `src/main.tsx` builds it, and components read its signals and call its functions.
- **Routes live in `src/app.tsx`** as preact-iso `<Route>`s; links are plain `<a href>`.
- **Style with Tailwind classes and the theme tokens** (`bg-surface`, `text-ink`, `text-muted`, `bg-accent`, `border-hairline`, `rounded-control`), never raw colours or arbitrary values: add a token to `@theme`, and its dark value, instead. Every page follows the OS light/dark setting. A `class` is a string literal or a `cx()` call so lint can check every class.
- **Parse what comes from outside** (storage, the network, the URL) with valibot at the boundary, and handle the failure where it's parsed.
- **Side effects are injected.** Components and logic take their collaborators (storage, fetch, timers, the clock) as props or parameters, typed as the smallest interface they use; only `src/main.tsx` builds the real ones.
- **Imports** carry their `.ts` / `.tsx` extension, and use `~/` (→ `src/`) for anything outside the current folder. No default exports in `src/`.
- **Tests** query by role with Testing Library and drive the UI with `userEvent.setup()`. Coverage is enforced per file (functions 100%, statements 75%); `src/main.tsx` is left to the e2e tests.

{{> agents/code-style.md}}

{{> agents/testing.md}}

{{> agents/comments.md}}
