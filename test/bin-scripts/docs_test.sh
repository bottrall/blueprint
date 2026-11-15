# shellcheck shell=bash
# bin/docs

test_docs_runs_rake_docs() {
  repo ruby
  rake_tasks docs docs:serve docs:check
  run bin/docs
  assert_calls 'bundle exec rake docs'
}

test_docs_serve_runs_rake_docs_serve() {
  repo ruby
  rake_tasks docs docs:serve docs:check
  run bin/docs --serve
  assert_calls 'bundle exec rake docs:serve'
}

test_docs_check_runs_rake_docs_check() {
  repo ruby
  rake_tasks docs docs:serve docs:check
  run bin/docs --check
  assert_calls 'bundle exec rake docs:check'
}

test_docs_rejects_serve_with_check() {
  repo ruby
  rake_tasks docs docs:serve docs:check
  run bin/docs --serve --check
  assert_status 2
}

test_docs_without_the_task_says_so() {
  repo ruby
  rake_tasks docs
  run bin/docs --check
  assert_output "no rake docs:check task; nothing to do"
}

test_docs_without_the_task_succeeds() {
  repo ruby
  run bin/docs
  assert_status 0
}

test_docs_ts_says_there_is_no_rake() {
  repo ts
  run bin/docs
  assert_output "no Gemfile, so no rake docs task; nothing to do"
}

test_docs_fails_when_rake_fails() {
  repo ruby
  rake_tasks docs
  fails 'bundle exec rake docs'
  run bin/docs
  assert_status 1
}
