#!/usr/bin/env bats

load ../../../../helpers/all_helpers
load ../../../../helpers/lib_helpers/stdlib_helpers

@test "stdlib: __from_json_array: typical case" {
  run_stdin '[1,"foo"]' __from_json_array

  assert_success
  echo -e "1\nfoo" | assert_output
}

@test "stdlib: __from_json_array: empty values are removed" {
  run_stdin '["foo", null, "bar", "", "baz"]' __from_json_array

  assert_success
  echo -e "foo\nbar\nbaz" | assert_output
}

@test "stdlib: __from_json_array: invalid JSON" {
  run_stdin 'not json' __from_json_array

  assert_failure ""
}
