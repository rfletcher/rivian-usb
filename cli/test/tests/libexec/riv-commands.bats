#!/usr/bin/env bats

load ../../helpers/all_helpers

@test "commands: without arguments" {
  run riv commands

  assert_success
  assert_line '/^  commands /'
  assert_line '/^  help /'
}

@test "commands: sort output" {
  run riv commands -s

  assert_success
  assert_line "commands"
  assert_line "help"
  refute_line "template"
}
