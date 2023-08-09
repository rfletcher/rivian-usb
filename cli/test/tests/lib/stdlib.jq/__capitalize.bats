#!/usr/bin/env bats

load ../../../helpers/all_helpers
load ../../../helpers/jq_helpers

@test "jq stdlib: __capitalize: no arguments" {
  run_jq __capitalize

  assert_success_json null
}

@test "jq stdlib: __capitalize: typical arguments" {
  run_jq_stdin '"foobar"' __capitalize

  assert_success_json '"Foobar"'
}

@test "jq stdlib: __capitalize: mixed-case input" {
  run_jq_stdin '"FOObar"' __capitalize

  assert_success_json '"Foobar"'
}

@test "jq stdlib: __capitalize: multi-word input" {
  run_jq_stdin '"hello, WORLD!"' __capitalize

  assert_success_json '"Hello, World!"'
}
