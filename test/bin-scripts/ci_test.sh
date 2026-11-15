# shellcheck shell=bash
# bin/ci

ci_workflow() {
  file .github/workflows/ci.yml "name: ci
on: pull_request
jobs:
  check:
    strategy:
      fail-fast: false
      matrix:
        include:
          - name: lint
            run: bin/lint
          - name: typecheck
            run: \"bin/typecheck\"
          - name: test 3.4
            run: bin/test
          - name: test 4.0
            run: bin/test
          - name: e2e
            run: bin/e2e # against the production build
    steps:
      - run: bin/setup
      - run: \${{ matrix.run }}
"
}

test_ci_runs_each_script_ci_runs_once_in_order() {
  repo mixed
  file Steepfile
  file tsconfig.json '{}'
  file e2e/playwright.config.ts
  ci_workflow
  run bin/ci
  assert_calls \
    'bundle exec rake lint' 'pnpm exec oxlint' 'pnpm exec oxfmt --check' \
    'bundle exec rake typecheck' 'pnpm exec tsc --noEmit' \
    'bundle exec rake test' 'pnpm exec vitest run --coverage' \
    'pnpm exec playwright test --config e2e/playwright.config.ts'
}

test_ci_passes_when_every_script_passes() {
  repo ruby
  ci_workflow
  run bin/ci
  assert_status 0
}

test_ci_runs_every_script_after_one_fails() {
  repo ruby
  file Steepfile
  ci_workflow
  fails 'bundle exec rake lint*'
  run bin/ci
  assert_calls 'bundle exec rake lint' 'bundle exec rake typecheck' 'bundle exec rake test'
}

test_ci_fails_when_a_script_fails() {
  repo ruby
  ci_workflow
  fails 'bundle exec rake test*'
  run bin/ci
  assert_status 1
}

test_ci_names_the_scripts_that_failed() {
  repo ruby
  ci_workflow
  fails 'bundle exec rake test*'
  run bin/ci
  assert_output "bin/ci: bin/test failed"
}

test_ci_passes_arguments_ci_gives() {
  repo mixed
  file .github/workflows/ci.yml "jobs:
  check:
    strategy:
      matrix:
        include:
          - run: bin/test --only=ruby
"
  run bin/ci
  assert_calls 'bundle exec rake test'
}

test_ci_refuses_a_workflow_that_fixes() {
  repo ruby
  file .github/workflows/ci.yml "jobs:
  check:
    steps:
      - run: bin/lint --fix
"
  run bin/ci
  assert_status 2
}

test_ci_without_a_workflow_fails() {
  repo ruby
  run bin/ci
  assert_status 1
}

test_ci_rejects_arguments() {
  repo ruby
  ci_workflow
  run bin/ci --fix
  assert_status 2
}
