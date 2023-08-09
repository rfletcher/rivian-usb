#!/usr/bin/env bats

load ../../../helpers/all_helpers
load ../../../helpers/lib_helpers/stdlib_helpers

@test "stdlib: __require_lib: without arguments" {
  run __require_lib

  assert_failure ""
}

@test "stdlib: __require_lib: libraries missing" {
  run __require_lib some_dependency

  assert_failure "/missing libraries.*some_dependency/"
}

# @test "stdlib: __require_lib: dependencies present" {
#   run __require_lib some_dependency
#
#   assert_success ""
# }
#
# @test "stdlib: __require_lib: mixed results" {
#   run __require_lib some_dependency another_dependency
#
#   assert_failure "/missing libraries.*another_dependency/"
# }
