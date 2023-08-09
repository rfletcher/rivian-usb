#!/usr/bin/env bats

load ../../../helpers/all_helpers
load ../../../helpers/lib_helpers/stdlib_helpers

@test "stdlib: __justify: without arguments" {
  run __justify

  assert_failure ""
}

@test "stdlib: __justify: typical use" {
  run __justify 5 foo

  assert_success "foo  "
}

@test "stdlib: __justify: explicit left justification" {
  run __justify "-5" foo

  assert_success "foo  "
}

@test "stdlib: __justify: right justification" {
  run __justify "5-" foo

  assert_success "  foo"
}

@test "stdlib: __justify: center justification" {
  run __justify "-5-" foo

  assert_success " foo "
}

@test "stdlib: __justify: imprecise center justification" {
  run __justify "-6-" foo

  assert_success "  foo "
}

@test "stdlib: __justify: left: not enough room" {
  run __justify "-2" foo

  assert_success "foo"
}
@test "stdlib: __justify: center: not enough room" {
  run __justify "-2-" foo

  assert_success "foo"
}
@test "stdlib: __justify: right: not enough room" {
  run __justify "2-" foo

  assert_success "foo"
}
