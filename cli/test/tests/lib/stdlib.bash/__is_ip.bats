#!/usr/bin/env bats

load ../../../helpers/all_helpers
load ../../../helpers/lib_helpers/stdlib_helpers

@test "stdlib: __is_ip: without arguments" {
  run __is_ip
  assert_failure
}

@test "stdlib: __is_ip: IP address" {
  run __is_ip 1.2.3.4
  assert_success
}

@test "stdlib: __is_ip: invalid IP address" {
  run __is_ip notanip
  assert_failure
}
