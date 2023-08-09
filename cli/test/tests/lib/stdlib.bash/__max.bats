#!/usr/bin/env bats

load ../../../helpers/all_helpers
load ../../../helpers/lib_helpers/stdlib_helpers

@test "stdlib: __max: typical case" {
  run __max 100 4,000 6 30.49

  assert_success "4000"
}

@test "stdlib: __max: without arguments" {
  run __max

  assert_failure ""
}
