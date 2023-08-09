#!/usr/bin/env bats

load ../../../helpers/all_helpers
load ../../../helpers/lib_helpers/stdlib_helpers

@test "stdlib: __error: without arguments" {
  run __error

  assert_failure "/Error/"
}

@test "stdlib: __error: with a custom message" {
  run __error "this is my message"

  assert_failure "/this is my message/"
}
