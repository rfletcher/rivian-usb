#!/usr/bin/env bats

load ../../../../helpers/all_helpers
load ../../../../helpers/lib_helpers/stdlib_helpers

@test "stdlib: __json_pluck: no arguments" {
  run __json_pluck

  assert_failure
}

@test "stdlib: __json_pluck: >1 argument" {
  run __json_pluck a b

  assert_failure
}

@test "stdlib: __json_pluck: typical case" {
  run_stdin '[{"id":1},{"id":2}]' __json_pluck id

  assert_success_json '[1,2]'
}

@test "stdlib: __json_pluck: missing properties" {
  run_stdin '[{"id":1},{"x":2},{"id":3}]' __json_pluck id

  assert_success_json '[1,null,3]'
}
