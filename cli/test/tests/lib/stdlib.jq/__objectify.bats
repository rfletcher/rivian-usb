#!/usr/bin/env bats

load ../../../helpers/all_helpers
load ../../../helpers/jq_helpers

@test "jq stdlib: __objectify: no arguments" {
  run_jq __objectify

  assert_failure
}

@test "jq stdlib: __objectify: typical use" {
  run_jq_stdin '[1,2]' '__objectify(["a","b"])'

  assert_success_json '{ "a": 1, "b": 2 }'
}
