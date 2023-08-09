#!/usr/bin/env bats

load ../../../../helpers/all_helpers
load ../../../../helpers/lib_helpers/stdlib_helpers

@test "stdlib: __yaml_to_json: typical case" {
  YAML=$(echo -e "---\nfoo:\n- 1\n- bar")

  run_stdin "$YAML" __yaml_to_json

  assert_success '{"foo":[1,"bar"]}'
}
