#!/usr/bin/env bats

load ../../../helpers/all_helpers
load ../../../helpers/jq_helpers

@test "jq stdlib: __normalize_name: no arguments" {
  run_jq __normalize_name

  assert_failure
}

@test "jq stdlib: __normalize_name: typical arguments" {
  run_jq_stdin '"Cassandra-va-1 (b)"' __normalize_name

  assert_success_json '"Cassandra-va-1"'
}
