#!/usr/bin/env bats

load ../../../helpers/all_helpers
load ../../../helpers/lib_helpers/stdlib_helpers

@test "stdlib: __say: without arguments" {
  run __say

  assert_success "/: $/"
}

@test "stdlib: __say: with a message" {
  run __say "this is my message"

  assert_success "/this is my message/"
}

@test "stdlib: __say: escape sequences" {
  run __say "line1\nline2"

  assert_line "/line1$/"
  assert_line "/line2$/"
  assert_success
}

@test "stdlib: __say: with echo options" {
  run __say -n "line1\nline2"

  assert_success '/line1\\nline2$/'
}

@test "stdlib: __say: indentation" {
  function test() {
    __say foo

    __increase_indent
    __say foo

    __increase_indent
    __say foo

    __decrease_indent
    __say foo

    __reset_indent
    __say foo
  }

  run test

  assert_success
  assert_line 0 '/: foo$/'
  assert_line 1 '/:   foo$/'
  assert_line 2 '/:     foo$/'
  assert_line 3 '/:   foo$/'
  assert_line 4 '/: foo$/'
}
