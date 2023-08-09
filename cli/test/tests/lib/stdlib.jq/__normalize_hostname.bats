#!/usr/bin/env bats

load ../../../helpers/all_helpers
load ../../../helpers/jq_helpers

@test "jq stdlib: __normalize_hostname: no arguments" {
  run_jq __normalize_hostname

  assert_failure
}

@test "jq stdlib: __normalize_hostname: typical arguments" {
  run_jq_stdin '"Cassandra-va-1 (b)"' __normalize_hostname

  assert_success_json '"cassandra-va-1"'
}
