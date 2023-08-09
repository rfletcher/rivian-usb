#!/usr/bin/env bats

load ../../../helpers/all_helpers
load ../../../helpers/lib_helpers/stdlib_helpers

@test "stdlib: __indent: simple case" {
  run_stdin $'foo\nbar' __indent

  assert_success $'  foo\n  bar'
}

@test "stdlib: __indent: preserves existing indentation" {
  run_stdin $'foo\n  bar\nbaz' __indent

  assert_success $'  foo\n    bar\n  baz'
}

@test "stdlib: __indent: non-default indentation" {
  run_stdin "$(echo -e 'foo\nbar')" __indent 8

  assert_success $'        foo\n        bar'
}
