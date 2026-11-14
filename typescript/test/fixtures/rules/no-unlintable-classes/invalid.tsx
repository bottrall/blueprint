function cx(...parts: unknown[]) {
  return parts.filter(Boolean).join(" ");
}

function lookupTone() {
  return "text-red-700";
}

const tone = "text-red-700";

export function Badge(props: { active: boolean }) {
  return (
    <ul>
      <li class={tone}>class from a plain variable</li> {/* ✗ */}
      <li className={`${tone} p-2`}>className from a template</li> {/* ✗ */}
      <li class={lookupTone()}>class from a call</li> {/* ✗ */}
      <li class={cx(tone)}>cx() over a plain variable</li> {/* ✗ */}
      <li class={cx(props.active ? tone : "p-2")}>cx() over a hidden branch</li> {/* ✗ */}
      <li class={cx("p-2", props.active || lookupTone())}>cx() over a hidden fallback</li> {/* ✗ */}
    </ul>
  );
}
