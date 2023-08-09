#!/usr/bin/env bats

load ../../../helpers/all_helpers
load ../../../helpers/jq_helpers

@test "jq stdlib: __sort_hostnames: no arguments" {
  run_jq __sort_hostnames

  assert_failure
}

@test "jq stdlib: __sort_hostnames: typical use" {
  run_jq_stdin '["api-1", "api-10", "api-2"]' __sort_hostnames

  assert_success_json '["api-1", "api-2", "api-10"]'
}
