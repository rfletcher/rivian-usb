#!/usr/bin/env bats

load ../../../helpers/all_helpers
load ../../../helpers/lib_helpers/stdlib_helpers

@test "stdlib: __mask_secret: typical case" {
  run __mask_secret "my password"

  assert_success
  assert_output "*****************ord"
}

@test "stdlib: __mask_secret: long input" {
  run __mask_secret "012345678900123456789001234567890"

  assert_success
  assert_output "****************7890"
}

@test "stdlib: __mask_secret: short input" {
  run __mask_secret "asdf"

  assert_success
  assert_output "*******************f"
}

@test "stdlib: __mask_secret: very short input" {
  run __mask_secret "x"

  assert_success
  assert_output "********************"
}
