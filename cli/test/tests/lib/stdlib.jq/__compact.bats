#!/usr/bin/env bats

load ../../../helpers/all_helpers
load ../../../helpers/jq_helpers

@test "jq stdlib: __compact: no arguments" {
  run_jq __compact

  assert_success null
}

@test "jq stdlib: __compact: array argument" {
  run_jq_stdin "[1,null,2,null]" __compact

  assert_success_json "[1,2]"
}

@test "jq stdlib: __compact: object argument" {
  run_jq_stdin '{ "foo": null, "bar": 1 }' __compact

  assert_success_json '{ "bar": 1 }'
}

@test "jq stdlib: __compact: boolean is untouched" {
  run_jq_stdin '{ "foo": false, "bar": [1,false,2] }' __compact

  assert_success_json '{ "foo": false, "bar": [1,false,2] }'
}
