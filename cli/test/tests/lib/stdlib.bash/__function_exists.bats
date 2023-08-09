#!/usr/bin/env bats

load ../../../helpers/all_helpers
load ../../../helpers/lib_helpers/stdlib_helpers

@test "stdlib: __function_exists: without arguments" {
  run __function_exists

  assert_failure ""
}

@test "stdlib: __function_exists: typical usage" {
  function foo() { true; }

  run __function_exists foo

  assert_success ""
}

@test "stdlib: __function_exists: undefined function" {
  run __function_exists foo

  assert_failure ""
}

@test "stdlib: __function_exists: is case sensitive" {
  function Foo() { true; }

  run __function_exists foo
  assert_failure ""
  run __function_exists Foo
  assert_success ""
}
