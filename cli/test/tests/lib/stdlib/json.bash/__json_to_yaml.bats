#!/usr/bin/env bats

load ../../../../helpers/all_helpers
load ../../../../helpers/lib_helpers/stdlib_helpers

@test "stdlib: __json_to_yaml: typical case" {
  run_stdin '{ "foo": [1,"bar"]}' __json_to_yaml

  assert_success
  echo -e "---\nfoo:\n- 1\n- bar" | assert_output
}
