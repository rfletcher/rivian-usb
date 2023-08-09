#!/usr/bin/env bats

load ../../../helpers/all_helpers
load ../../../helpers/lib_helpers/stdlib_helpers

@test "stdlib: __to_lower: typical case" {
  run_stdin "$(echo A Value)" __to_lower

  assert_success "a value"
}

@test "stdlib: __to_lower: empty input" {
  run_stdin "" __to_lower

  assert_success ""
}

# @test "stdlib: __to_lower: accented characters" {
#   run_stdin "$(echo A ValÜe)" __to_lower
#
#   assert_success "a valüe"
# }
