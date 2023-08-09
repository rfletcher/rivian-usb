#!/usr/bin/env bats

load ../../../helpers/all_helpers
load ../../../helpers/jq_helpers

@test "jq stdlib: __toupper: no arguments" {
  run_jq __toupper

  assert_success_json null
}

@test "jq stdlib: __toupper: typical arguments" {
  run_jq_stdin '"FOObar"' __toupper

  assert_success_json '"FOOBAR"'
}
