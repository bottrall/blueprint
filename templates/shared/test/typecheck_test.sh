# shellcheck shell=bash
# bin/typecheck

test_typecheck_ruby_runs_rake_typecheck() {
  repo ruby
  file Steepfile
  run bin/typecheck
  assert_calls 'bundle exec rake typecheck'
}

test_typecheck_ruby_passes_flags_as_steep_opts() {
  repo ruby
  file Steepfile
  run bin/typecheck --log-level=info
  assert_calls 'bundle exec rake typecheck STEEP_OPTS=--log-level=info'
}

test_typecheck_ruby_without_steepfile_runs_nothing() {
  repo ruby
  run bin/typecheck
  assert_calls
}

test_typecheck_ruby_without_steepfile_says_so() {
  repo ruby
  run bin/typecheck
  assert_output "no Steepfile, so no Ruby to type-check; skipping"
}

test_typecheck_ts_runs_tsc() {
  repo ts
  file tsconfig.json '{}'
  run bin/typecheck
  assert_calls 'pnpm exec tsc --noEmit'
}

test_typecheck_plain_js_succeeds() {
  repo ts
  run bin/typecheck
  assert_status 0
}

test_typecheck_plain_js_says_so() {
  repo ts
  run bin/typecheck
  assert_output "no tsconfig.json, so no TypeScript to type-check; skipping"
}

test_typecheck_mixed_runs_ruby_then_ts() {
  repo mixed
  file Steepfile
  file tsconfig.json '{}'
  run bin/typecheck
  assert_calls 'bundle exec rake typecheck' 'pnpm exec tsc --noEmit'
}

test_typecheck_mixed_runs_ts_after_ruby_fails() {
  repo mixed
  file Steepfile
  file tsconfig.json '{}'
  fails 'bundle exec rake typecheck*'
  run bin/typecheck
  assert_calls 'bundle exec rake typecheck' 'pnpm exec tsc --noEmit'
}

test_typecheck_mixed_fails_when_ruby_fails() {
  repo mixed
  file Steepfile
  file tsconfig.json '{}'
  fails 'bundle exec rake typecheck*'
  run bin/typecheck
  assert_status 1
}

test_typecheck_mixed_rejects_runner_flags_for_both_stacks() {
  repo mixed
  file Steepfile
  file tsconfig.json '{}'
  run bin/typecheck --pretty
  assert_status 2
}

test_typecheck_mixed_only_ts_takes_runner_flags() {
  repo mixed
  file Steepfile
  file tsconfig.json '{}'
  run bin/typecheck --only=ts --pretty false
  assert_calls 'pnpm exec tsc --noEmit --pretty false'
}
