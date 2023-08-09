#!/usr/bin/env bats

load ../../../../helpers/all_helpers
load ../../../../helpers/lib_helpers/stdlib_helpers

@test "stdlib: __validate_no_expansion: no arguments" {
  run __validate_no_expansion

  assert_success ""
}

@test "stdlib: __validate_no_expansion: with expansion" {
  run __validate_no_expansion "{1,2}"

  assert_error "/cannot include expansion/"
}

@test "stdlib: __validate_no_expansion: without expansion" {
  run __validate_no_expansion "some value"

  assert_success ""
}

@test "stdlib: __validate_no_expansion: custom label" {
  run __validate_no_expansion "{1,2}" "Field"

  assert_error "/Field/"
}
