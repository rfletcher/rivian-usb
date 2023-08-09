#!/usr/bin/env bats

load ../../../helpers/all_helpers
load ../../../helpers/lib_helpers/stdlib_helpers

@test "stdlib: __urlencode: without arguments" {
  run __urlencode

  assert_success ""
}

@test "stdlib: __urlencode: typical case" {
  run __urlencode "%foo bar/baz?"

  assert_success "%25foo%20bar%2Fbaz%3F"
}

@test "stdlib: __urlencode: handling spaces" {
  run __urlencode "foo bar"

  assert_success "foo%20bar"
}
