# shellcheck shell=bash
# bin/test

test_test_ruby_runs_rake_test() {
  repo ruby
  run bin/test
  assert_calls 'bundle exec rake test'
}

test_test_ts_runs_vitest_with_coverage() {
  repo ts
  run bin/test
  assert_calls 'pnpm exec vitest run --coverage'
}

test_test_mixed_runs_ruby_then_ts() {
  repo mixed
  run bin/test
  assert_calls 'bundle exec rake test' 'pnpm exec vitest run --coverage'
}

test_test_mixed_runs_ts_after_ruby_fails() {
  repo mixed
  fails 'bundle exec rake test*'
  run bin/test
  assert_calls 'bundle exec rake test' 'pnpm exec vitest run --coverage'
}

test_test_mixed_fails_when_ruby_fails() {
  repo mixed
  fails 'bundle exec rake test*'
  run bin/test
  assert_status 1
}

test_test_mixed_fails_when_ts_fails() {
  repo mixed
  fails 'pnpm exec vitest*'
  run bin/test
  assert_status 1
}

test_test_mixed_passes_when_both_pass() {
  repo mixed
  run bin/test
  assert_status 0
}

test_test_ruby_fails_when_rake_fails() {
  repo ruby
  fails 'bundle exec rake test*'
  run bin/test
  assert_status 1
}

test_test_mixed_routes_each_path_to_its_runner() {
  repo mixed
  run bin/test test/a_test.rb web/app.test.tsx test/b_test.rb
  assert_calls 'bundle exec rake test TEST=test/a_test.rb\,test/b_test.rb' 'pnpm exec vitest run web/app.test.tsx'
}

test_test_mixed_starts_only_ruby_for_ruby_paths() {
  repo mixed
  run bin/test lib/a_test.rb
  assert_calls 'bundle exec rake test TEST=lib/a_test.rb'
}

test_test_mixed_starts_only_ts_for_ts_paths() {
  repo mixed
  run bin/test web/a.test.ts
  assert_calls 'pnpm exec vitest run web/a.test.ts'
}

test_test_mixed_sends_ts_files_under_test_to_vitest() {
  repo mixed
  run bin/test test/a.test.ts
  assert_calls 'pnpm exec vitest run test/a.test.ts'
}

test_test_mixed_sends_test_directory_to_minitest_as_a_glob() {
  repo mixed
  file test/models/a_test.rb
  run bin/test test/models
  assert_calls 'bundle exec rake test TEST=test/models/\*\*/\*_test.rb'
}

test_test_mixed_rejects_a_path_of_neither_stack() {
  repo mixed
  run bin/test README.md
  assert_status 2
}

test_test_mixed_names_only_for_a_path_of_neither_stack() {
  repo mixed
  run bin/test README.md
  assert_output "can't tell whether README.md is Ruby or TS; pass --only=ruby or --only=ts"
}

test_test_mixed_runs_nothing_for_a_path_of_neither_stack() {
  repo mixed
  run bin/test test/a_test.rb README.md
  assert_calls
}

test_test_mixed_rejects_runner_flags_for_both_stacks() {
  repo mixed
  run bin/test --seed 1
  assert_status 2
}

test_test_mixed_names_only_for_runner_flags_for_both_stacks() {
  repo mixed
  run bin/test --seed 1
  assert_output "pass --only=ruby or --only=ts"
}

test_test_mixed_rejects_runner_flags_for_paths_of_both_stacks() {
  repo mixed
  run bin/test -v test/a_test.rb web/a.test.ts
  assert_calls
}

test_test_mixed_allows_runner_flags_when_paths_pick_one_stack() {
  repo mixed
  run bin/test -v test/a_test.rb
  assert_calls 'bundle exec rake test TEST=test/a_test.rb TESTOPTS=-v'
}

test_test_mixed_only_ruby_runs_only_ruby() {
  repo mixed
  run bin/test --only=ruby
  assert_calls 'bundle exec rake test'
}

test_test_mixed_only_ts_runs_only_ts() {
  repo mixed
  run bin/test --only=ts
  assert_calls 'pnpm exec vitest run --coverage'
}

test_test_mixed_only_sends_every_path_to_that_stack() {
  repo mixed
  run bin/test --only=ts test/a_test.rb
  assert_calls 'pnpm exec vitest run test/a_test.rb'
}

test_test_joins_minitest_flag_values_onto_their_flags() {
  repo ruby
  run bin/test --seed 1 -n /pattern/ --verbose
  assert_calls 'bundle exec rake test TESTOPTS=--seed=1\ -n/pattern/\ --verbose'
}

test_test_keeps_minitest_flag_values_out_of_test_files() {
  repo ruby
  run bin/test test/a_test.rb --name /x/
  assert_calls 'bundle exec rake test TEST=test/a_test.rb TESTOPTS=--name=/x/'
}

test_test_ruby_sends_every_path_to_minitest() {
  repo ruby
  run bin/test spec/a.ts
  assert_calls 'bundle exec rake test TEST=spec/a.ts'
}

test_test_ts_passes_flags_and_paths_to_vitest_without_coverage() {
  repo ts
  run bin/test -t adds web/a.test.ts
  assert_calls 'pnpm exec vitest run -t adds web/a.test.ts'
}

test_test_ts_passes_flags_to_vitest_without_coverage() {
  repo ts
  run bin/test --reporter=verbose
  assert_calls 'pnpm exec vitest run --reporter=verbose'
}

test_test_watch_runs_vitest_watch() {
  repo ts
  run bin/test --watch
  assert_calls 'pnpm exec vitest watch'
}

test_test_mixed_watch_implies_only_ts() {
  repo mixed
  run bin/test --watch web/a.test.ts
  assert_calls 'pnpm exec vitest watch web/a.test.ts'
}

test_test_mixed_watch_allows_runner_flags() {
  repo mixed
  run bin/test --watch -t adds
  assert_calls 'pnpm exec vitest watch -t adds'
}

test_test_watch_names_vitest_with_only_ruby() {
  repo mixed
  run bin/test --watch --only=ruby
  assert_output "--watch runs vitest, so it can't go with --only=ruby"
}

test_test_watch_rejects_only_ruby() {
  repo mixed
  run bin/test --watch --only=ruby
  assert_status 2
}

test_test_ruby_watch_says_there_is_no_package_json() {
  repo ruby
  run bin/test --watch
  assert_output "--watch runs vitest, and there's no package.json"
}

test_test_only_ts_rejects_a_ruby_repo() {
  repo ruby
  run bin/test --only=ts
  assert_status 2
}

test_test_only_ruby_rejects_a_ts_repo() {
  repo ts
  run bin/test --only=ruby
  assert_output "--only=ruby, but there's no Gemfile"
}

test_test_only_rejects_an_unknown_stack() {
  repo mixed
  run bin/test --only=python
  assert_output "--only takes ruby or ts, not 'python'"
}

test_test_without_a_stack_says_so() {
  repo none
  run bin/test
  assert_output "no Gemfile or package.json; nothing to do"
}

test_test_without_a_stack_succeeds() {
  repo none
  run bin/test
  assert_status 0
}

test_test_runs_from_any_directory() {
  repo ruby
  mkdir -p lib
  cd lib
  run ../bin/test
  assert_calls 'bundle exec rake test'
}
