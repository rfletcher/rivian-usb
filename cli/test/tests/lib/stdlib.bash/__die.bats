#!/usr/bin/env bats

load ../../../helpers/all_helpers
load ../../../helpers/lib_helpers/stdlib_helpers

@test "stdlib: __die: without arguments" {
  run __die

  assert_failure ""
}

@test "stdlib: __die: with a custom message" {
  run __die "this is my message"

  assert_failure "/this is my message/"
}
