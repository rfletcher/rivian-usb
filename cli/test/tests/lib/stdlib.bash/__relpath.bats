#!/usr/bin/env bats

load ../../../helpers/all_helpers
load ../../../helpers/lib_helpers/stdlib_helpers

@test "stdlib: __relpath: too few arguments" {
  run __relpath

  assert_error
}

@test "stdlib: __relpath: too many arguments" {
  run __relpath a b c

  assert_error
}

@test "stdlib: __relpath: one argument" {
  run __relpath ./foo

  assert_success "foo"
}

@test "stdlib: __relpath: two arguments" {
  run __relpath ./foo ./bar/baz

  assert_success "../bar/baz"
}

@test "stdlib: __relpath: absolute paths" {
  run __relpath /usr/local/bin /opt/riv/bin/riv

  assert_success "../../../opt/riv/bin/riv"
}
