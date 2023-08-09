#!/usr/bin/env bats

load ../../../helpers/all_helpers
load ../../../helpers/lib_helpers/stdlib_helpers

@test "stdlib: __if_not_dry_run: without arguments" {
  run __if_not_dry_run

  assert_success
}

@test "stdlib: __if_not_dry_run: not a dry run" {
  run __if_not_dry_run "" bash -c 'echo $((1+1))'

  assert_success 2
}

@test "stdlib: __if_not_dry_run: dry run" {
  run __if_not_dry_run 1 bash -c 'echo $((1+1))'

  assert_success "/dry run/"
  assert_line 1 '  bash -c echo\ \$\(\(1+1\)\)'
}

@test "stdlib: __if_not_dry_run: indent" {
  run __if_not_dry_run -i "" bash -c 'echo $((1+1))'

  assert_success "/^[[:space:]]+2$/"
}
