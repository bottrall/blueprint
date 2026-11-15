#!/usr/bin/env bash
# Runs one bin/ script in each package (ruby/, typescript/), always both, and
# exits non-zero if either failed. Sourced by the root bin/ scripts.
run_each() {
  local script=$1 status=0
  shift
  for pkg in ruby typescript; do
    echo "==> ${pkg}: bin/${script} $*"
    (cd "$pkg" && "bin/${script}" "$@") || status=1
  done
  return "$status"
}

# The tests for the starter bin/ scripts in templates/common/bin.
run_template_tests() {
  test/bin-scripts/run
}
