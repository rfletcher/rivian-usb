#!/usr/bin/env bats

load ../../../helpers/all_helpers
load ../../../helpers/lib_helpers/stdlib_helpers

@test "stdlib: __abspath: too few arguments" {
  run __abspath

  assert_error
}

@test "stdlib: __abspath: too many arguments" {
  run __abspath a b

  assert_error
}

@test "stdlib: __abspath: one argument" {
  run __abspath ./foo

  assert_success '/^\/.*\/foo$/'
}

@test "stdlib: __abspath: absolute path" {
  run __abspath /usr/local/bin

  assert_success /usr/local/bin
}
