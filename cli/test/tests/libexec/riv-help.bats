#!/usr/bin/env bats

load ../../helpers/all_helpers

@test "help: without arguments" {
  run riv help

  assert_help_output
}

@test "help: is the default command" {
  run riv

  assert_help_output
}

@test "help: usage-only" {
  run riv help -u help

  assert_success
  assert_usage_output
}

@test "help: -u without a command argument" {
  run riv help -u

  assert_failure
  assert_usage_output
}

@test "help: via \`riv -h\`" {
  run riv -h

  assert_help_output
}

@test "help: via \`riv --help\`" {
  run riv --help

  assert_help_output
}

assert_help_output() {
  assert_success

  assert_line 1 'Usage: riv <command> [<args...>]'
  assert_line '/^Some useful commands/'
  assert_line '/See `riv help <command>`/'
}

assert_usage_output() {
  assert_line 0 '/^Usage: /'
  refute_line 1
}
