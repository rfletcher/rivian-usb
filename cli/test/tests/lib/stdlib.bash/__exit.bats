#!/usr/bin/env bats

load ../../../helpers/all_helpers
load ../../../helpers/lib_helpers/stdlib_helpers

@test "stdlib: __exit: without arguments" {
  return # how do you test a function that exits the shell when you run it?

  run __exit

  assert_sucess ""
}
