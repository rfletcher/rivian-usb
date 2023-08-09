#!/usr/bin/env bats

load ../../../../helpers/all_helpers
load ../../../../helpers/lib_helpers/stdlib_helpers

@test "stdlib: __json_merge: requires arguments" {
  run __json_merge

  assert_failure
}

@test "stdlib: __json_merge: arrays" {
  run __json_merge '[1,3]' '[2]'

  assert_success '[1,3,2]'
}

@test "stdlib: __json_merge: objects" {
  run __json_merge '{ "x": 1, "y": 2, "z": 3 }' '{ "y": 4 }'

  assert_success
  assert_json_equal $output '{ "x": 1, "y": 4, "z": 3 }'
}

@test "stdlib: __json_merge: arbitrary number of arguments" {
  run __json_merge '[]' '[2]' '[3,4]' '[1]'

  assert_success '[2,3,4,1]'
}

@test "stdlib: __json_merge: arguments with spaces" {
  run __json_merge '"string one"' '"string two"'

  assert_success '"string onestring two"'
}
