#!/usr/bin/env bats

load ../../../helpers/all_helpers
load ../../../helpers/lib_helpers/stdlib_helpers

@test "stdlib: __min: typical case" {
  run __min 100 4,000 6 30.49

  assert_success "6"
}

@test "stdlib: __min: without arguments" {
  run __min

  assert_failure ""
}
