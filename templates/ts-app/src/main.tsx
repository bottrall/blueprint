import { render } from "preact";

import { App } from "./app.tsx";
import { counter } from "./modules/counter/index.ts";

import "./styles.css";

const root = document.querySelector("#app");

if (root) {
  render(<App counter={counter(localStorage, "count")} />, root);
}
