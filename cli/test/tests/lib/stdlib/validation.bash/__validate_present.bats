#!/usr/bin/env bats

load ../../../../helpers/all_helpers
load ../../../../helpers/lib_helpers/stdlib_helpers

@test "stdlib: __validate_present: no arguments" {
  run __validate_present

  assert_error "/empty/"
}

@test "stdlib: __validate_present: an argument" {
  run __validate_present "a value"

  assert_success ""
}

@test "stdlib: __validate_present: custom label" {
  run __validate_present "" "Field"

  assert_error "/Field/"
}
