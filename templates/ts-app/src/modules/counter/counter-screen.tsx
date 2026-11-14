import type { Counter } from "./counter.ts";

interface Props {
  counter: Counter;
}

export function CounterScreen({ counter }: Props) {
  return (
    <section class="flex flex-col items-start gap-4">
      <h1 class="text-2xl font-semibold">Counter</h1>
      <output aria-label="Count" class="text-5xl font-semibold tabular-nums">
        {counter.count}
      </output>
      <button
        type="button"
        class="rounded-control bg-accent px-4 py-2 font-medium text-on-accent"
        onClick={() => counter.increment()}
      >
        Add one
      </button>
    </section>
  );
}
