#!/usr/bin/env bats

load ../../../helpers/all_helpers
load ../../../helpers/lib_helpers/stdlib_helpers

# @test "stdlib: __strip_heredoc: without arguments" {
#   run __strip_heredoc
#
#   assert_success ""
# }

@test "stdlib: __strip_heredoc: empty input" {
  run_stdin "" __strip_heredoc

  assert_success ""
}

@test "stdlib: __strip_heredoc: typical input" {
  run_stdin "  foo"$'\n'"    bar" __strip_heredoc

  assert_success "foo"$'\n'"  bar"
}

@test "stdlib: __strip_heredoc: specific indent" {
  run_stdin "  foo"$'\n'"    bar" __strip_heredoc 3

  assert_success "   foo"$'\n'"     bar"
}
