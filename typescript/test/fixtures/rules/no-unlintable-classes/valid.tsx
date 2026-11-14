function cx(...parts: unknown[]) {
  return parts.filter(Boolean).join(" ");
}

const buttonClasses = "rounded px-3";

const cardClassNames = { base: "shadow" };

export function Button(props: { active: boolean; class?: string; className?: string }) {
  return (
    <ul>
      <li class="p-2">class literal</li>
      <li className="p-2">className literal</li>
      <li class={"p-2"}>class expression literal</li>
      <li class={`p-2`}>class template without expressions</li>
      <li class={cx("p-2", props.active && "font-bold")}>cx() with a condition</li>
      <li class={cx(props.active ? "font-bold" : "font-normal")}>cx() with a ternary</li>
      <li class={cx(buttonClasses, cardClassNames.base, props.class, props.className)}>references</li>
      <li class={cx(cx("p-2"), undefined, null, false)}>nested cx() and empty values</li>
      <li class={cx("p-2" || "p-4")}>cx() with a visible fallback</li>
      <li data-class={buttonClasses.length}>not a class attribute</li>
      <li class>bare attribute</li>
    </ul>
  );
}
