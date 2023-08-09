#!/usr/bin/env bats

load ../../../../helpers/all_helpers
load ../../../../helpers/lib_helpers/stdlib_helpers

@test "stdlib: __jq: typical case" {
  run_stdin "true" __jq "__truthy"

  assert_success
}
