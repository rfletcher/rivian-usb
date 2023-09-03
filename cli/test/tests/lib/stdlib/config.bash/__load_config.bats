#!/usr/bin/env bats

load ../../../../helpers/all_helpers
load ../../../../helpers/lib_helpers/stdlib_helpers

@test "stdlib: __load_config: no arguments" {
  export RIV_CONFIG_JSON=

  run __load_config

  assert_success
  assert_output ""
}

@test "stdlib: __load_config: >0 arguments" {
  export RIV_CONFIG_JSON=

  run __load_config one

  assert_failure
}

@test "stdlib: __load_config: non-existant supplemental path" {
  export RIV_CONFIG_JSON=
  export RIV_CONFIG=/path/that/does/not/exist

  run __load_config

  assert_failure
  assert_error
}

@test "stdlib: __load_config: config is cached" {
  export RIV_CONFIG_JSON="x"

  run __get_config

  assert_success "x"
}
