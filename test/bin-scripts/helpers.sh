# shellcheck shell=bash
# Fixtures and assertions for the bin/ tests. Each test function runs in its
# own subshell, in a fresh repo made by `repo`; an assertion that doesn't hold
# prints why and exits that subshell.

# repo ruby|ts|mixed|none: a fresh repo with the bin/ scripts, a Gemfile, a
# package.json, both or neither, made the current directory.
repo() {
  REPO="$WORK/repos/$TEST_NAME"
  mkdir -p "$REPO" "$WORK/stubs"
  cp -R "$BIN" "$REPO/bin"
  cd "$REPO"
  case $1 in
    ruby) touch Gemfile ;;
    ts) echo '{}' >package.json ;;
    mixed) touch Gemfile && echo '{}' >package.json ;;
    none) ;;
  esac

  cp "$HERE/stub" "$WORK/stubs/bundle"
  cp "$HERE/stub" "$WORK/stubs/pnpm"
  export PATH="$WORK/stubs:$PATH"
  export STUB_LOG="$WORK/repos/$TEST_NAME.calls"
  export STUB_RAKE_TASKS="" STUB_FAIL=""
  : >"$STUB_LOG"
}

# file path [content]: a file in the repo, with any directories it needs.
file() {
  mkdir -p "$(dirname "$1")"
  printf '%s' "${2:-}" >"$1"
}

# rake_tasks task...: the tasks `bundle exec rake -P` lists.
rake_tasks() { export STUB_RAKE_TASKS="$*"; }

# fails glob...: stub commands matching any glob exit 1.
fails() {
  STUB_FAIL=$(printf '%s\n' "$@")
  export STUB_FAIL
}

# run bin/script [args...]: runs it, keeping its exit status and output.
run() {
  set +e
  OUTPUT=$("$@" 2>&1)
  STATUS=$?
  set -e
}

flunk() {
  printf '%s\n' "$@"
  printf 'output was:\n%s\n' "$OUTPUT"
  exit 1
}

# assert_calls line...: the stubs were called with exactly these command
# lines, in this order (none if no lines are given).
assert_calls() {
  local expected actual
  expected=$(if (($#)); then printf '%s\n' "$@"; fi)
  actual=$(cat "$STUB_LOG")
  if [[ $actual != "$expected" ]]; then
    flunk "expected calls:" "$expected" "actual calls:" "$actual"
  fi
}

assert_status() {
  if [[ $STATUS != "$1" ]]; then flunk "expected exit status $1, got $STATUS"; fi
}

assert_output() {
  if [[ $OUTPUT != *"$1"* ]]; then flunk "expected output to contain: $1"; fi
}
