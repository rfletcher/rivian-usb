#!/usr/bin/env bats

load ../../../helpers/all_helpers
load ../../../helpers/jq_helpers

@test "jq stdlib: __flatten: no arguments" {
  run_jq __flatten

  assert_failure
}

@test "jq stdlib: __flatten: nested array" {
  run_jq_stdin "[1,[2,3],4]" __flatten

  assert_success_json "[1,2,3,4]"
}

@test "jq stdlib: __flatten: non-array input" {
  run_jq_stdin 1 __flatten

  assert_failure
}
