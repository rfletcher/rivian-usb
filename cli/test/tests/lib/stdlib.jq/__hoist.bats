#!/usr/bin/env bats

load ../../../helpers/all_helpers
load ../../../helpers/jq_helpers

@test "jq stdlib: __hoist: no arguments" {
  run_jq __hoist

  assert_failure
}

@test "jq stdlib: __hoist: typical use, numeric keys" {
  run_jq_stdin '[{"a": 1, "b": 2}, {"a": 2, "b": 3}]' '__hoist("a")'

  assert_success_json '{ "1":[{ "b": 2 }], "2": [{ "b": 3 }] }'
}

@test "jq stdlib: __hoist: typical use, string keys" {
  run_jq_stdin '[{"a": "w", "b": "x"}, {"a": "y", "b": "z"}]' '__hoist("a")'

  assert_success_json '{ "w":[{ "b": "x" }], "y": [{ "b": "z" }] }'
}
