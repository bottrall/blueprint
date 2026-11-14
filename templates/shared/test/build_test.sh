# shellcheck shell=bash
# bin/build

test_build_ruby_runs_rake_build() {
  repo ruby
  rake_tasks build test
  run bin/build
  assert_calls 'bundle exec rake build'
}

test_build_ruby_without_a_build_task_runs_nothing() {
  repo ruby
  rake_tasks test
  run bin/build
  assert_calls
}

test_build_ruby_without_a_build_task_says_so() {
  repo ruby
  rake_tasks test
  run bin/build
  assert_output "no rake build task; skipping"
}

test_build_ts_runs_vite_build() {
  repo ts
  file vite.config.ts
  run bin/build
  assert_calls 'pnpm exec vite build'
}

test_build_ts_without_a_vite_config_succeeds() {
  repo ts
  run bin/build
  assert_status 0
}

test_build_mixed_runs_ruby_then_ts() {
  repo mixed
  rake_tasks build
  file vite.config.ts
  run bin/build
  assert_calls 'bundle exec rake build' 'pnpm exec vite build'
}

test_build_mixed_runs_ts_after_ruby_fails() {
  repo mixed
  rake_tasks build
  file vite.config.ts
  fails 'bundle exec rake build*'
  run bin/build
  assert_calls 'bundle exec rake build' 'pnpm exec vite build'
}

test_build_mixed_fails_when_ts_fails() {
  repo mixed
  rake_tasks build
  file vite.config.ts
  fails 'pnpm exec vite build*'
  run bin/build
  assert_status 1
}

test_build_mixed_only_ts_passes_flags_with_values() {
  repo mixed
  file vite.config.ts
  run bin/build --only=ts --mode staging
  assert_calls 'pnpm exec vite build --mode staging'
}

test_build_mixed_rejects_runner_flags_for_both_stacks() {
  repo mixed
  run bin/build --mode staging
  assert_status 2
}
