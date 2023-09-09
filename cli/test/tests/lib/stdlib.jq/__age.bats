#!/usr/bin/env bats

load ../../../helpers/all_helpers
load ../../../helpers/jq_helpers

@test "jq stdlib: __age: no arguments" {
  run_jq __age

  assert_success_json null
}

@test "jq stdlib: __age: iso8601 format" {
  run_jq_stdin "\"$(test_date)\"" __age

  assert_success_json 3600 || assert_success_json 3601
}

function test_date() {
  local DATE_BIN=$(which gdate || which date)
  $DATE_BIN -u +"%Y-%m-%dT%H:%M:%SZ" --date "1 hour ago"
}
