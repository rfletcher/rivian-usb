#!/usr/bin/env bats

load ../../../helpers/all_helpers
load ../../../helpers/lib_helpers/stdlib_helpers

findmnt() {
  echo -n "/"
}

@test "stdlib: __find_mount: without arguments" {
  run __find_mount

  assert_failure
}

@test "stdlib: __find_mount: existing path" {
  run __find_mount /tmp

  assert_success
  assert_output /
}

@test "stdlib: __find_mount: nonexistant path" {
  run __find_mount /tmp/foo/bar

  assert_success
  assert_output /
}
