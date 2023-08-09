#!/usr/bin/env bats

load ../../../helpers/all_helpers
load ../../../helpers/lib_helpers/stdlib_helpers

@test "stdlib: __pad: without arguments" {
  run __pad

  assert_failure ""
}

@test "stdlib: __pad: typical use" {
  run __pad 1 foo

  assert_success " foo "
}
