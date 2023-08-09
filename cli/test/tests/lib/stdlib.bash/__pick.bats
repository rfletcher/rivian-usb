#!/usr/bin/env bats

load ../../../helpers/all_helpers
load ../../../helpers/lib_helpers/stdlib_helpers

@test "stdlib: __pick: typical case" {
  run __pick "" "" false "foo" "bar"

  assert_success false
}

@test "stdlib: __pick: no value" {
  run __pick "" ""

  assert_failure
}
