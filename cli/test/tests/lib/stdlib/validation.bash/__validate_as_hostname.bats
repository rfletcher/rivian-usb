#!/usr/bin/env bats

load ../../../../helpers/all_helpers
load ../../../../helpers/lib_helpers/stdlib_helpers

@test "stdlib: __validate_as_hostname: without arguments" {
  run __validate_as_hostname

  assert_success ""
}

@test "stdlib: __validate_as_hostname: valid" {
  run __validate_as_hostname "valid-value" "Label"

  assert_success ""
}

@test "stdlib: __validate_as_hostname: invalid" {
  run __validate_as_hostname "invalid value" "Label"

  assert_error "/Label .* contain/"
}

@test "stdlib: __validate_as_hostname: custom label" {
  run __validate_as_hostname "invalid value" "Field"

  assert_error "/Field/"
}
