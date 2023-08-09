#!/usr/bin/env bats

load ../../../helpers/all_helpers
load ../../../helpers/jq_helpers

@test "jq stdlib: __coerce: string input" {
  run_jq_stdin '"Foo"' __coerce

  assert_success_json '"Foo"'
}

@test "jq stdlib: __coerce: non-string input" {
  run_jq_stdin '[1,2,3]' __coerce

  assert_success_json '[1,2,3]'
}

@test "jq stdlib: __coerce: numeric values" {
  run_jq_stdin '"123"' __coerce
  assert_success_json 123
  run_jq_stdin '"123.5"' __coerce
  assert_success_json 123.5
  run_jq_stdin '"-123"' __coerce
  assert_success_json -123
  run_jq_stdin '"-123.5"' __coerce
  assert_success_json -123.5
}

@test "jq stdlib: __coerce: boolean values" {
  run_jq_stdin '"true"' __coerce
  assert_success_json true
  run_jq_stdin '"false"' __coerce
  assert_success_json false
  run_jq_stdin '"TrUe"' __coerce
  assert_success_json true
}

@test "jq stdlib: __coerce: null" {
  run_jq_stdin '"null"' __coerce
  assert_success_json null
}
