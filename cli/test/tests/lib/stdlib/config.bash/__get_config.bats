#!/usr/bin/env bats

load ../../../../helpers/all_helpers
load ../../../../helpers/lib_helpers/stdlib_helpers

@test "stdlib: __get_config: no arguments" {
  run __get_config

  assert_success
  assert_json
}

@test "stdlib: __get_config: >1 arguments" {
  run __get_config one two

  assert_failure
}

@test "stdlib: __get_config: selectors are supported" {
  run __get_config object/key1

  assert_success value1
}

@test "stdlib: __get_config: supplemental config is merged into defaults" {
  run __get_config command_defaults/install

  assert_success
  assert_json
}

@test "stdlib: __get_config: not found" {
  run __get_config path/not/present

  assert_success ""
}
