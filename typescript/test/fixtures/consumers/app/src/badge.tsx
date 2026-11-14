import { useState } from "react";

function cx(...parts: unknown[]) {
  return parts.filter(Boolean).join(" ");
}

const tone = "text-red-700";

export default function Badge(props: { active: boolean }) {
  const [label] = useState("badge");
  return (
    <ul>
      <li class="brand-glow">{label}</li>
      <li class="p-2 p-4">conflicting</li>
      <li className="mystery-class">unknown</li>
      <li class={cx("flex flex", props.active && "font-bold")}>duplicate</li>
      <li class={tone}>hidden</li>
    </ul>
  );
}
