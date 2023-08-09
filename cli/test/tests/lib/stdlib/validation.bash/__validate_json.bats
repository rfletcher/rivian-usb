#!/usr/bin/env bats

load ../../../../helpers/all_helpers
load ../../../../helpers/lib_helpers/stdlib_helpers

@test "stdlib: __validate_json: no arguments" {
  run __validate_json

  assert_error
}

@test "stdlib: __validate_json: valid JSON input" {
  run __validate_json "{}"

  assert_success ""
}

@test "stdlib: __validate_json: invalid JSON input" {
  run __validate_json "{1}"

  assert_error
}

@test "stdlib: __validate_json: explicit type with matching input" {
  run __validate_json "[]" array

  assert_success ""
}

@test "stdlib: __validate_json: explicit type without matching input" {
  run __validate_json "[]" object

  assert_error "/object.*array/"
}
