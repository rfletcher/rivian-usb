#!/usr/bin/env bats

load ../../../helpers/all_helpers
load ../../../helpers/lib_helpers/stdlib_helpers

@test "stdlib: __join: without arguments" {
  run __join

  assert_failure ""
}

@test "stdlib: __join: CSV" {
  run __join , a "b c" d

  assert_success "a,b c,d"
}

@test "stdlib: __join: path segments" {
  run __join / "" var log

  assert_success "/var/log"
}

@test "stdlib: __join: Bash array" {
  local PARTS=( a b c )

  run __join , "${PARTS[@]}"

  assert_success "a,b,c"
}

@test "stdlib: __join: newlines" {
  local PARTS=( a b c )

  run __join $'\n' "${PARTS[@]}"

  assert_success
  assert_line 0 a
  assert_line 1 b
  assert_line 2 c
}

@test "stdlib: __join: multi-char delimiter" {
  local PARTS=( a b c )

  run __join ', ' "${PARTS[@]}"

  assert_success "a, b, c"
}

@test "stdlib: __join: lines from stdin" {
  run_stdin "foo bar"$'\n'"baz" __join ', '

  assert_success "foo bar, baz"
}
