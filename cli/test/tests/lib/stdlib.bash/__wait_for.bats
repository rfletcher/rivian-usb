#!/usr/bin/env bats

load ../../../helpers/all_helpers
load ../../../helpers/lib_helpers/stdlib_helpers

function _setup() {
  local  WAIT_START=$(date +%s)
  export WAIT_STOP=$((WAIT_START + 3))
}

function _teardown() {
  unset WAIT_STOP
}

@test "stdlib: __wait_for: missing arguments" {
  run __wait_for

  assert_failure
}

@test "stdlib: __wait_for: success" {
  run __wait_for "wait_noop_callback"

  assert_success ""
}

@test "stdlib: __wait_for: custom message" {
  run __wait_for "wait_noop_callback" 1 "something custom"

  assert_success "/something custom/"
}

@test "stdlib: __wait_for: delayed success" {
  run __wait_for "wait_callback"

  assert_success
}

@test "stdlib: __wait_for: timeout" {
  run __wait_for "false" 1 "" 2

  assert_failure
}

function wait_callback() {
  local NOW=$(date +%s)

  [[ "$NOW" -ge "$WAIT_STOP" ]]
}

function wait_noop_callback() {
  true
}
