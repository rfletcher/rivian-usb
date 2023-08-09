#!/usr/bin/env bats

load ../../../helpers/all_helpers
load ../../../helpers/jq_helpers

@test "jq stdlib: __intersection: no arguments" {
  run_jq __intersection

  assert_failure
}

@test "jq stdlib: __intersection: typical use" {
  run_jq_stdin '[[1,2,4],[2,4,5],[4,5,6]]' __intersection

  assert_success_json '[4]'
}

@test "jq stdlib: __intersection: typical use, no intersection" {
  run_jq_stdin '[[1,2],[3,4]]' __intersection

  assert_success_json '[]'
}
