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

# The tests for templates/: the shared bin/ scripts and, once it exists, the
# instantiate script.
run_template_tests() {
  local status=0
  templates/shared/test/run || status=1
  if [[ -x templates/test/run ]]; then templates/test/run || status=1; fi
  return "$status"
}
