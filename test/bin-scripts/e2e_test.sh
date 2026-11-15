# shellcheck shell=bash
# bin/e2e

test_e2e_runs_playwright() {
  repo ts
  file e2e/playwright.config.ts
  run bin/e2e
  assert_calls 'pnpm exec playwright test --config e2e/playwright.config.ts'
}

test_e2e_passes_paths_and_flags_to_playwright() {
  repo ts
  file e2e/playwright.config.ts
  run bin/e2e e2e/home.spec.ts --project chromium
  assert_calls 'pnpm exec playwright test --config e2e/playwright.config.ts e2e/home.spec.ts --project chromium'
}

test_e2e_mixed_runs_only_playwright() {
  repo mixed
  file e2e/playwright.config.ts
  run bin/e2e --only=ts
  assert_calls 'pnpm exec playwright test --config e2e/playwright.config.ts'
}

test_e2e_fails_when_playwright_fails() {
  repo ts
  file e2e/playwright.config.ts
  fails 'pnpm exec playwright*'
  run bin/e2e
  assert_status 1
}

test_e2e_without_a_config_succeeds() {
  repo ts
  run bin/e2e
  assert_status 0
}

test_e2e_without_a_config_says_so() {
  repo ruby
  run bin/e2e
  assert_output "no e2e/playwright.config.ts; nothing to do"
}

test_e2e_rejects_only_ruby() {
  repo mixed
  file e2e/playwright.config.ts
  run bin/e2e --only=ruby
  assert_status 2
}
