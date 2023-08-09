#!/usr/bin/env bats

load ../../../helpers/all_helpers
load ../../../helpers/lib_helpers/stdlib_helpers

@test "stdlib: __urldecode: without arguments" {
  run __urldecode

  assert_success ""
}

@test "stdlib: __urldecode: typical case" {
  run __urldecode "%25foo%20bar%2Fbaz%3F"

  assert_success "%foo bar/baz?"
}

@test "stdlib: __urldecode: handling spaces" {
  run __urldecode "foo+%20bar"

  assert_success "foo+ bar"
}
