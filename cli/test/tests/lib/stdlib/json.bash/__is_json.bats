#!/usr/bin/env bats

load ../../../../helpers/all_helpers
load ../../../../helpers/lib_helpers/stdlib_helpers

@test "stdlib: __is_json: valid JSON" {
  run __is_json "{}"

  assert_success
}

@test "stdlib: __is_json: invalid JSON" {
  run __is_json "foo"

  assert_failure
}
