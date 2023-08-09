#!/usr/bin/env bats

load ../../helpers/all_helpers

@test "commands: without arguments" {
  run riv dependencies

  assert_success
  refute_line "/#/"
}

@test "commands: binaries only" {
  run riv dependencies -b

  assert_success
  refute_line "/:/"
}

@test "commands: packages only" {
  run riv dependencies -p

  assert_success
  refute_line "/:/"
}

@test "commands: conflicting output types" {
  run riv dependencies -b -p

  assert_error
}
