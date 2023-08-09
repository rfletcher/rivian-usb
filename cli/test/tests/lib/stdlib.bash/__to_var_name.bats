#!/usr/bin/env bats

load ../../../helpers/all_helpers
load ../../../helpers/lib_helpers/stdlib_helpers

@test "stdlib: __to_var_name: typical case" {
  run_stdin "$(echo -e '\nFoo-\t BAR  ')" __to_var_name

  assert_success
  assert_output "FOO_BAR"
}

@test "stdlib: __to_var_name: path" {
  run_stdin "/foo/bar/baz" __to_var_name

  assert_success
  assert_output "FOO_BAR_BAZ"
}

@test "stdlib: __to_var_name: empty input" {
  run_stdin "" __to_var_name

  assert_success
  assert_output "_"
}

@test "stdlib: __to_var_name: bad leading character(s)" {
  run_stdin " 19_blah" __to_var_name

  assert_success
  assert_output "BLAH"
}

@test "stdlib: __to_var_name: invalid characters" {
  run_stdin "VigLink, Inc." __to_var_name

  assert_success
  assert_output "VIGLINK_INC"
}
