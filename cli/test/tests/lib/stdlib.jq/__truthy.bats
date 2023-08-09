#!/usr/bin/env bats

load ../../../helpers/all_helpers
load ../../../helpers/jq_helpers

@test "jq stdlib: __truthy: no arguments" {
  run_jq __truthy

  assert_success_json false
}

@test "jq stdlib: __truthy: boolean" {
  run_jq_stdin true __truthy
  assert_success_json true

  run_jq_stdin false __truthy
  assert_success_json false
}

@test "jq stdlib: __truthy: number" {
  run_jq_stdin 0 __truthy
  assert_success_json false

  run_jq_stdin 123 __truthy
  assert_success_json true
}

@test "jq stdlib: __truthy: string" {
  # empty string
  run_jq_stdin '""' __truthy
  assert_success_json false

  # non-empty string
  run_jq_stdin '"foo"' __truthy
  assert_success_json true
}

@test "jq stdlib: __truthy: array" {
  # empty array
  run_jq_stdin "[]" __truthy
  assert_success_json false

  # non-empty array
  run_jq_stdin "[null]" __truthy
  assert_success_json true
}

@test "jq stdlib: __truthy: object" {
  # empty object
  run_jq_stdin "{}" __truthy
  assert_success_json false

  # non-empty object
  run_jq_stdin "{ \"foo\": null }" __truthy
  assert_success_json true
}
