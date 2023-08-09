#!/usr/bin/env bats

load ../../../helpers/all_helpers
load ../../../helpers/jq_helpers

@test "jq stdlib: __trim: no arguments" {
  run_jq __trim

  assert_failure
}

@test "jq stdlib: __trim: typical arguments" {
  run_jq_stdin '" foo bar   "' __trim

  assert_success_json '"foo bar"'
}
