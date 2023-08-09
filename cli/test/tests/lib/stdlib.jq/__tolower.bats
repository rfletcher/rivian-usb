#!/usr/bin/env bats

load ../../../helpers/all_helpers
load ../../../helpers/jq_helpers

@test "jq stdlib: __tolower: no arguments" {
  run_jq __tolower

  assert_success_json null
}

@test "jq stdlib: __tolower: typical arguments" {
  run_jq_stdin '"FOObar"' __tolower

  assert_success_json '"foobar"'
}
