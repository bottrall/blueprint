# shellcheck shell=bash
# bin/check

test_check_mixed_fixes_then_typechecks_then_tests() {
  repo mixed
  file Steepfile
  file tsconfig.json '{}'
  run bin/check
  assert_calls \
    'bundle exec rake lint RUBOCOP_OPTS=-a' 'pnpm exec oxlint --fix' 'pnpm exec oxfmt --write' \
    'bundle exec rake typecheck' 'pnpm exec tsc --noEmit' \
    'bundle exec rake test' 'pnpm exec vitest run --coverage'
}

test_check_runs_every_step_after_one_fails() {
  repo ruby
  file Steepfile
  fails 'bundle exec rake lint*'
  run bin/check
  assert_calls 'bundle exec rake lint RUBOCOP_OPTS=-a' 'bundle exec rake typecheck' 'bundle exec rake test'
}

test_check_fails_when_a_step_fails() {
  repo ruby
  file Steepfile
  fails 'bundle exec rake typecheck*'
  run bin/check
  assert_status 1
}

test_check_passes_when_every_step_passes() {
  repo ts
  run bin/check
  assert_status 0
}

test_check_mixed_passes_only_to_every_step() {
  repo mixed
  file Steepfile
  file tsconfig.json '{}'
  run bin/check --only=ts
  assert_calls 'pnpm exec oxlint --fix' 'pnpm exec oxfmt --write' 'pnpm exec tsc --noEmit' 'pnpm exec vitest run --coverage'
}

test_check_rejects_other_arguments() {
  repo ruby
  run bin/check test/a_test.rb
  assert_status 2
}
