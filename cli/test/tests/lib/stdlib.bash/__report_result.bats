#!/usr/bin/env bats

load ../../../helpers/all_helpers
load ../../../helpers/lib_helpers/stdlib_helpers

@test "stdlib: __report_result: without arguments" {
  run __report_result

  assert_failure "/Error/"
}

@test "stdlib: __report_result: success" {
  run __report_result 0

  assert_success "/Done/"
}

@test "stdlib: __report_result: error" {
  run -127 __report_result 127

  assert_failure "/Error/"
}
