#!/usr/bin/env bats

load ../../../helpers/all_helpers
load ../../../helpers/jq_helpers

@test "jq stdlib: __as_array: no arguments" {
  run_jq __as_array

  assert_success_json null
}

@test "jq stdlib: __as_array: array argument" {
  local ARG='[1]'

  run_jq_stdin "$ARG" __as_array

  assert_success_json "$ARG"
}

@test "jq stdlib: __as_array: non-array argument" {
  local ARG='42'

  run_jq_stdin "$ARG" __as_array

  assert_success_json "[${ARG}]"
}
