#!/usr/bin/env bats

load ../../helpers/all_helpers

@test "version: without arguments" {
  run riv version

  assert_version_output
}

@test "version: long form output" {
  run riv version -l

  assert_version_output
  assert_line 0 '/ /'
}

@test "version: via \`riv -v\`" {
  run riv -v

  assert_version_output
}

@test "version: via \`riv --version\`" {
  run riv --version

  assert_version_output
}

function assert_version_output() {
  assert_success

  assert_line 0 '/^[^\s]+$/'
}
