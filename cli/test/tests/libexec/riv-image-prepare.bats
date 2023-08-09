#!/usr/bin/env bats

load ../../helpers/all_helpers

@test "commands: without arguments" {
  run riv image-prepare

  assert_failure
  assert_error "/[Rr]epository/"
}
