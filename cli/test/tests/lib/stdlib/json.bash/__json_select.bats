#!/usr/bin/env bats

load ../../../../helpers/all_helpers
load ../../../../helpers/lib_helpers/stdlib_helpers

_setup() {
  __filter_stub_array() {
    echo '[{"foo":"bar"},{"foo":"baz"}]' | __json_select "$@"
  }
  __filter_stub_object() {
    echo '{"foo": { "bar": "baz", "bool": false } }' | __json_select "$@"
  }
}

_teardown() {
  unset __filter_stub_object
}

@test "stdlib: __json_select: typical use" {
  run __filter_stub_object foo/bar

  assert_success 'baz'
}

@test "stdlib: __json_select: json output" {
  run __filter_stub_object -j foo/bar

  assert_success '"baz"'
}

@test "stdlib: __json_select: complex value" {
  run __filter_stub_object foo

  assert_success_json '{"bar":"baz", "bool":false}'
}

@test "stdlib: __json_select: non-existent path" {
  run __filter_stub_object asdf

  assert_success ''
}

@test "stdlib: __json_select: custom default" {
  run __filter_stub_object asdf foo

  assert_success foo
}

@test "stdlib: __json_select: empty default" {
  run __filter_stub_object -j asdf ""

  assert_success_json '""'
}

@test "stdlib: __json_select: custom default, coerced value" {
  run __filter_stub_object asdf null

  assert_success null
}

@test "stdlib: __json_select: custom default, false value" {
  run __filter_stub_object foo/bool true

  assert_success false
}

@test "stdlib: __json_select: custom default, json output" {
  run __filter_stub_object -j asdf foo

  assert_success_json '"foo"'
}

@test "stdlib: __json_select: custom default, json output, coerced value" {
  run __filter_stub_object -j asdf null

  assert_success_json null
}

@test "stdlib: __json_select: array input" {
  run __filter_stub_array foo

  assert_success_json '["bar","baz"]'
}
