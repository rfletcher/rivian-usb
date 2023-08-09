#!/usr/bin/env bats

load ../../../../helpers/all_helpers
load ../../../../helpers/lib_helpers/stdlib_helpers

@test "stdlib: __validate_exclusive: no arguments" {
  run __validate_exclusive

  assert_success
}

@test "stdlib: __validate_exclusive: one value present" {
  run __validate_exclusive "" "" "a value"

  assert_success ""
}

@test "stdlib: __validate_exclusive: multiple values present" {
  run __validate_exclusive "one" "" "another"

  assert_failure
}
