# shellcheck shell=bash
# bin/setup

test_setup_ruby_installs_the_bundle_then_runs_rake_setup() {
  repo ruby
  run bin/setup
  assert_calls 'bundle install' 'bundle exec rake setup'
}

test_setup_ruby_stops_when_bundle_install_fails() {
  repo ruby
  fails 'bundle install*'
  run bin/setup
  assert_calls 'bundle install'
}

test_setup_ts_installs_packages() {
  repo ts
  run bin/setup
  assert_calls 'pnpm install'
}

test_setup_mixed_runs_ruby_then_ts() {
  repo mixed
  run bin/setup
  assert_calls 'bundle install' 'bundle exec rake setup' 'pnpm install'
}

test_setup_mixed_runs_ts_after_ruby_fails() {
  repo mixed
  fails 'bundle install*'
  run bin/setup
  assert_calls 'bundle install' 'pnpm install'
}

test_setup_mixed_fails_when_ruby_fails() {
  repo mixed
  fails 'bundle exec rake setup'
  run bin/setup
  assert_status 1
}

test_setup_mixed_rejects_runner_flags_for_both_stacks() {
  repo mixed
  run bin/setup --frozen-lockfile
  assert_status 2
}

test_setup_mixed_only_ts_takes_runner_flags() {
  repo mixed
  run bin/setup --only=ts --frozen-lockfile
  assert_calls 'pnpm install --frozen-lockfile'
}

test_setup_mixed_only_ruby_passes_flags_to_bundle_install() {
  repo mixed
  run bin/setup --only=ruby --jobs 4
  assert_calls 'bundle install --jobs 4' 'bundle exec rake setup'
}
