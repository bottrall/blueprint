# shellcheck shell=bash
# bin/lint

test_lint_ruby_runs_rake_lint() {
  repo ruby
  run bin/lint
  assert_calls 'bundle exec rake lint'
}

test_lint_ruby_fix_passes_autocorrect() {
  repo ruby
  run bin/lint --fix
  assert_calls 'bundle exec rake lint RUBOCOP_OPTS=-a'
}

test_lint_ruby_passes_flags_and_paths_to_rubocop() {
  repo ruby
  run bin/lint --fix --format simple lib/a.rb
  assert_calls 'bundle exec rake lint RUBOCOP_OPTS=-a\ --format\ simple\ lib/a.rb'
}

test_lint_ts_runs_oxlint_then_oxfmt() {
  repo ts
  run bin/lint
  assert_calls 'pnpm exec oxlint' 'pnpm exec oxfmt --check'
}

test_lint_ts_fix_fixes_and_formats() {
  repo ts
  run bin/lint --fix
  assert_calls 'pnpm exec oxlint --fix' 'pnpm exec oxfmt --write'
}

test_lint_ts_passes_flags_to_oxlint_and_paths_to_both() {
  repo ts
  run bin/lint --quiet web/a.ts
  assert_calls 'pnpm exec oxlint --quiet web/a.ts' 'pnpm exec oxfmt --check web/a.ts'
}

test_lint_ts_runs_oxfmt_after_oxlint_fails() {
  repo ts
  fails 'pnpm exec oxlint*'
  run bin/lint
  assert_calls 'pnpm exec oxlint' 'pnpm exec oxfmt --check'
}

test_lint_ts_fails_when_oxlint_fails() {
  repo ts
  fails 'pnpm exec oxlint*'
  run bin/lint
  assert_status 1
}

test_lint_ts_fails_when_oxfmt_fails() {
  repo ts
  fails 'pnpm exec oxfmt*'
  run bin/lint
  assert_status 1
}

test_lint_mixed_runs_ruby_then_ts() {
  repo mixed
  run bin/lint
  assert_calls 'bundle exec rake lint' 'pnpm exec oxlint' 'pnpm exec oxfmt --check'
}

test_lint_mixed_fix_fixes_both() {
  repo mixed
  run bin/lint --fix
  assert_calls 'bundle exec rake lint RUBOCOP_OPTS=-a' 'pnpm exec oxlint --fix' 'pnpm exec oxfmt --write'
}

test_lint_mixed_runs_ts_after_ruby_fails() {
  repo mixed
  fails 'bundle exec rake lint*'
  run bin/lint
  assert_calls 'bundle exec rake lint' 'pnpm exec oxlint' 'pnpm exec oxfmt --check'
}

test_lint_mixed_fails_when_ruby_fails() {
  repo mixed
  fails 'bundle exec rake lint*'
  run bin/lint
  assert_status 1
}

test_lint_mixed_routes_each_path_to_its_linter() {
  repo mixed
  run bin/lint lib/a.rb web/b.tsx Gemfile
  assert_calls 'bundle exec rake lint RUBOCOP_OPTS=lib/a.rb\ Gemfile' 'pnpm exec oxlint web/b.tsx' 'pnpm exec oxfmt --check web/b.tsx'
}

test_lint_mixed_starts_only_ts_for_ts_paths() {
  repo mixed
  run bin/lint --fix web/b.ts
  assert_calls 'pnpm exec oxlint --fix web/b.ts' 'pnpm exec oxfmt --write web/b.ts'
}

test_lint_mixed_rejects_a_path_of_neither_stack() {
  repo mixed
  run bin/lint docs/
  assert_status 2
}

test_lint_mixed_rejects_runner_flags_for_both_stacks() {
  repo mixed
  run bin/lint --quiet
  assert_output "--quiet can only go to one stack's runner; pass --only=ruby or --only=ts"
}

test_lint_mixed_allows_fix_for_both_stacks() {
  repo mixed
  run bin/lint --fix
  assert_status 0
}

test_lint_mixed_only_ts_takes_runner_flags() {
  repo mixed
  run bin/lint --only=ts --quiet
  assert_calls 'pnpm exec oxlint --quiet' 'pnpm exec oxfmt --check'
}
