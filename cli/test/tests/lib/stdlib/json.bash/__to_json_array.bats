#!/usr/bin/env bats

load ../../../../helpers/all_helpers
load ../../../../helpers/lib_helpers/stdlib_helpers

@test "stdlib: __to_json_array: typical case" {
  run_stdin "$(echo -e '1\nfoo')" __to_json_array

  assert_success_json '["1","foo"]'
}

@test "stdlib: __to_json_array: empty input" {
  run_stdin '' __to_json_array

  assert_success_json '[]'
}

@test "stdlib: __to_json_array: escaping characters" {
  run_stdin "$(echo -e '["foo"]')" __to_json_array

  assert_success_json '["[\"foo\"]"]'
}
