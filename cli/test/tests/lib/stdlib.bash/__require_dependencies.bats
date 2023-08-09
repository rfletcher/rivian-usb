#!/usr/bin/env bats

load ../../../helpers/all_helpers
load ../../../helpers/lib_helpers/stdlib_helpers

_setup() {
  some_dependency() {
    true
  }
}

_teardown() {
  unset some_dependency
}

@test "stdlib: __require_dependencies: without arguments" {
  run __require_dependencies

  assert_failure ""
}

@test "stdlib: __require_dependencies: dependencies missing" {
  unset some_dependency

  run __require_dependencies some_dependency

  assert_failure "/missing dependencies.*some_dependency/"
}

@test "stdlib: __require_dependencies: dependencies present" {
  run __require_dependencies some_dependency

  assert_success ""
}

@test "stdlib: __require_dependencies: mixed results" {
  run __require_dependencies some_dependency another_dependency

  assert_failure "/missing dependencies.*another_dependency/"
}
