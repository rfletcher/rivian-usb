#!/usr/bin/env bats

load ../../../helpers/all_helpers
load ../../../helpers/lib_helpers/stdlib_helpers

@test "stdlib: __in_array: existing item" {
  local HAYSTACK=( foo bar )
  run __in_array foo "${HAYSTACK[@]}"

  assert_success ""
}

@test "stdlib: __in_array: missing item" {
  local HAYSTACK=( foo bar )
  run __in_array baz "${HAYSTACK[@]}"

  assert_failure ""
}

@test "stdlib: __in_array: spaces" {
  local HAYSTACK=( "foo bar" baz )

  run __in_array foo "${HAYSTACK[@]}"
  assert_failure ""

  run __in_array "foo bar" "${HAYSTACK[@]}"
  assert_success ""
}

@test "stdlib: __in_array: empty item" {
  local HAYSTACK=( foo "" bar )
  run __in_array "" "${HAYSTACK[@]}"
  assert_success ""

  local HAYSTACK=( foo bar )
  run __in_array "" "${HAYSTACK[@]}"
  assert_failure ""
}
