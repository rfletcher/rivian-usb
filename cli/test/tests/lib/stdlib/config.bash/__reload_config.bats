#!/usr/bin/env bats

load ../../../../helpers/all_helpers
load ../../../../helpers/lib_helpers/stdlib_helpers

@test "stdlib: __reload_config: no arguments" {
  run __reload_config

  assert_success
  assert_output ""
}

@test "stdlib: __reload_config: >0 arguments" {
  run __reload_config one

  assert_failure
}

@test "stdlib: __reload_config: cache is overwritten" {
  export RIV_CONFIG_JSON="x"

  _reload_and_get() {
    __reload_config
    __get_config
  }

  run _reload_and_get

  assert_success
  refute_output "$RIV_CONFIG_JSON"
}
