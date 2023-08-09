#!/usr/bin/env bats

load ../../../helpers/all_helpers
load ../../../helpers/lib_helpers/stdlib_helpers

@test "stdlib: __is_url: without arguments" {
  run __is_url
  assert_failure
}

@test "stdlib: __is_url: http URL" {
  run __is_url http://example.com
  assert_success
}

@test "stdlib: __is_url: https URL" {
  run __is_url https://example.com
  assert_success
}

@test "stdlib: __is_url: complex URL" {
  run __is_url https://example.com:8080/?foo=bar
  assert_success
}

@test "stdlib: __is_url: invalid URL" {
  run __is_url notaurl
  assert_failure
}
