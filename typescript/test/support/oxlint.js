import { spawnSync } from "node:child_process";
import path from "node:path";
import { fileURLToPath } from "node:url";

export const packageRoot = fileURLToPath(new URL("../..", import.meta.url));

const oxlintBin = path.join(packageRoot, "node_modules", ".bin", "oxlint");

function toDiagnostic(diagnostic) {
  return {
    file: diagnostic.filename,
    rule: diagnostic.code ?? "",
    line: diagnostic.labels[0]?.span.line ?? 0,
    message: diagnostic.message,
  };
}

// Run the real oxlint CLI from `cwd` with an explicit config, returning one entry per diagnostic.
export function runOxlint({ cwd, config, targets }) {
  const result = spawnSync(oxlintBin, ["--format", "json", "--config", config, ...targets], {
    cwd,
    encoding: "utf8",
  });

  if (result.error) {
    throw result.error;
  }

  try {
    return JSON.parse(result.stdout).diagnostics.map((diagnostic) => toDiagnostic(diagnostic));
  } catch {
    throw new Error(`oxlint did not produce a JSON report:\n${result.stdout}\n${result.stderr}`);
  }
}
