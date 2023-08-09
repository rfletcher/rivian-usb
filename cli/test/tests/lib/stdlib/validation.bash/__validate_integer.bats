#!/usr/bin/env bats

load ../../../../helpers/all_helpers
load ../../../../helpers/lib_helpers/stdlib_helpers

@test "stdlib: __validate_integer: without arguments" {
  run __validate_integer

  assert_error
}

@test "stdlib: __validate_integer: zero" {
  run __validate_integer 0

  assert_success ""
}

@test "stdlib: __validate_integer: positive integer" {
  run __validate_integer 1 "Label"

  assert_success ""
}

@test "stdlib: __validate_integer: non-numeric" {
  run __validate_integer "invalid value" "Label"

  assert_error "/Label/"
}

@test "stdlib: __validate_integer: negative" {
  run __validate_integer -1

  assert_error
}
