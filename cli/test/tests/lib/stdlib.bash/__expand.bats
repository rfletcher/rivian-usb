#!/usr/bin/env bats

load ../../../helpers/all_helpers
load ../../../helpers/lib_helpers/stdlib_helpers

@test "stdlib: __expand: without arguments" {
  run __expand

  assert_success ""
}

@test "stdlib: __expand: without expansion" {
  run __expand "some value"

  assert_success "some value"
}

@test "stdlib: __expand: with quoted expansion" {
  run __expand "{1..3}"

  assert_success "1 2 3"
}

@test "stdlib: __expand: with unquoted expansion" {
  run __expand {1..3}

  assert_success "1 2 3"
}
