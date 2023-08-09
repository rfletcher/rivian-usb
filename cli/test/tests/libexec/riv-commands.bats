#!/usr/bin/env bats

load ../../helpers/all_helpers

@test "commands: without arguments" {
  run riv commands

  assert_success
  assert_line "/^commands /"
  assert_line "/^help /"
}

@test "commands: quiet output" {
  run riv commands --command-only

  assert_success
  assert_line "commands"
  assert_line "help"
  refute_line "template"
}
