import { LocationProvider, Route, Router } from "preact-iso";

import { type Counter, CounterScreen } from "~/modules/counter/index.ts";

interface Props {
  counter: Counter;
}

function Home() {
  return (
    <section class="flex flex-col gap-2">
      <h1 class="text-2xl font-semibold">{{name}}</h1>
      <p class="text-muted">Edit src/app.tsx to begin.</p>
    </section>
  );
}

function NotFound() {
  return <h1 class="text-2xl font-semibold">Page not found</h1>;
}

export function App({ counter }: Props) {
  return (
    <LocationProvider>
      <div class="mx-auto flex min-h-screen max-w-2xl flex-col gap-8 p-6">
        <nav class="flex gap-4 border-b border-hairline pb-4">
          <a href="/" class="text-accent hover:underline">
            Home
          </a>
          <a href="/counter" class="text-accent hover:underline">
            Counter
          </a>
        </nav>
        <main>
          <Router>
            <Route path="/" component={Home} />
            <Route path="/counter" component={CounterScreen} counter={counter} />
            <Route default component={NotFound} />
          </Router>
        </main>
      </div>
    </LocationProvider>
  );
}
