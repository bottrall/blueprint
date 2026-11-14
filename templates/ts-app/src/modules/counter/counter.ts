import { computed, signal } from "@preact/signals";
import { integer, pipe, safeParse, string, toNumber } from "valibot";

interface KeyValueStorage {
  getItem: (key: string) => string | null;
  setItem: (key: string, value: string) => void;
}

const storedCount = pipe(string(), toNumber(), integer());

function load(storage: KeyValueStorage, key: string) {
  const parsed = safeParse(storedCount, storage.getItem(key));
  return parsed.success ? parsed.output : 0;
}

export function counter(storage: KeyValueStorage, key: string) {
  const count = signal(load(storage, key));
  return {
    count: computed(() => count.value),
    increment() {
      count.value += 1;
      storage.setItem(key, String(count.value));
    },
  };
}

export type Counter = ReturnType<typeof counter>;
