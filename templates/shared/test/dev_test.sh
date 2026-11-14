# shellcheck shell=bash
# bin/dev

test_dev_ts_runs_mprocs() {
  repo ts
  file mprocs.yaml
  file vite.config.ts
  run bin/dev
  assert_calls 'pnpm exec mprocs'
}

test_dev_mixed_prefers_mprocs_to_rake_dev() {
  repo mixed
  file mprocs.yaml
  rake_tasks dev
  run bin/dev
  assert_calls 'pnpm exec mprocs'
}

test_dev_ruby_runs_rake_dev() {
  repo ruby
  rake_tasks dev
  run bin/dev
  assert_calls 'bundle exec rake dev'
}

test_dev_mixed_without_mprocs_runs_rake_dev() {
  repo mixed
  file vite.config.ts
  rake_tasks dev
  run bin/dev
  assert_calls 'bundle exec rake dev'
}

test_dev_ts_without_mprocs_runs_vite() {
  repo ts
  file vite.config.ts
  run bin/dev
  assert_calls 'pnpm exec vite'
}

test_dev_ruby_without_a_dev_task_says_so() {
  repo ruby
  rake_tasks test
  run bin/dev
  assert_output "no mprocs.yaml, rake dev task or vite.config; nothing to do"
}

test_dev_ruby_without_a_dev_task_succeeds() {
  repo ruby
  run bin/dev
  assert_status 0
}

test_dev_fails_when_the_server_fails() {
  repo ruby
  rake_tasks dev
  fails 'bundle exec rake dev'
  run bin/dev
  assert_status 1
}

test_dev_rejects_arguments() {
  repo ts
  file mprocs.yaml
  run bin/dev --port 3000
  assert_status 2
}
