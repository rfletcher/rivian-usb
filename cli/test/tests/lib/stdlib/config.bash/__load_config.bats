#!/usr/bin/env bats

load ../../../../helpers/all_helpers
load ../../../../helpers/lib_helpers/stdlib_helpers

@test "stdlib: __load_config: no arguments" {
  export _RIV_CONFIG=

  run __load_config

  assert_success
  assert_output ""
}

@test "stdlib: __load_config: >0 arguments" {
  export _RIV_CONFIG=

  run __load_config one

  assert_failure
}

@test "stdlib: __load_config: non-existant supplemental path" {
  export _RIV_CONFIG=
  export RIV_CONFIG=/path/that/does/not/exist

  run __load_config

  assert_failure
  assert_error
}

@test "stdlib: __load_config: config is cached" {
  export _RIV_CONFIG="x"

  run __get_config

  assert_success "x"
}
