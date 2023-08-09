#!/usr/bin/env bats

load ../../../helpers/all_helpers
load ../../../helpers/jq_helpers

@test "jq stdlib: __select: no arguments" {
  run_jq __select

  assert_failure
}

@test "jq stdlib: __select: typical use" {
  run_jq_stdin '{"a":{"b":1}}' '__select("a/b")'

  assert_success_json 1
}
