# shellcheck shell=bash
# bin/generate

test_generate_runs_rake_generate() {
  repo ruby
  rake_tasks generate generate:watch
  run bin/generate
  assert_calls 'bundle exec rake generate'
}

test_generate_watch_runs_rake_generate_watch() {
  repo ruby
  rake_tasks generate generate:watch
  run bin/generate --watch
  assert_calls 'bundle exec rake generate:watch'
}

test_generate_mixed_watch_runs_rake_generate_watch() {
  repo mixed
  rake_tasks generate generate:watch
  run bin/generate --watch
  assert_calls 'bundle exec rake generate:watch'
}

test_generate_without_the_task_says_so() {
  repo ruby
  rake_tasks generate
  run bin/generate --watch
  assert_output "no rake generate:watch task; nothing to do"
}

test_generate_without_the_task_succeeds() {
  repo ruby
  run bin/generate
  assert_status 0
}

test_generate_ts_says_there_is_no_rake() {
  repo ts
  run bin/generate
  assert_output "no Gemfile, so no rake generate task; nothing to do"
}

test_generate_fails_when_rake_fails() {
  repo ruby
  rake_tasks generate
  fails 'bundle exec rake generate'
  run bin/generate
  assert_status 1
}

test_generate_rejects_other_arguments() {
  repo ruby
  rake_tasks generate
  run bin/generate lib/a.rb
  assert_status 2
}
