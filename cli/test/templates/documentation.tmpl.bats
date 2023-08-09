#!/usr/bin/env bats

# This file was generated dynamically. Changes will be overwritten.

load ../../../helpers/all_helpers

@test "documentation: __COMMAND__ has documentation" {
  assert_sufficient_help_output "__COMMAND__"
}

# @test "documentation: __COMMAND__ has a summary" {
#  assert_command_summary "__COMMAND__"
# }
