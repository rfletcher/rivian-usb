##
# Test whether a key is present in a JSON object
#
function __json_has_key() {
  local KEY="$1"
  local JSON="${2:-$output}"

  jq --null-input \
    --exit-status \
    --argjson json "$JSON" \
    --arg key "$KEY" \
    '$json | has($key)' >/dev/null 2>&1
}

##
# Assert that a string is valid JSON
#
# Usage:
#   assert_json # no input? test $output
#   assert_json '[1]'
#
function assert_json() {
  local json

  if [ $# -eq 0 ]; then
    json="$output"
  else
    json="$1"
  fi

  if ! echo -n "$json" | jq . >/dev/null 2>&1; then
    flunk "Invalid JSON: $json"
  fi
}

##
# Assert that two JSON strings are equivalent
#
# Usage:
#   assert_json_equal '[1]' '[ 1 ]'
#
function assert_json_equal() {
  local EXPECTED="$1"
  local ACTUAL="${2:-$output}"

  assert_json "$EXPECTED"
  assert_json "$ACTUAL"

  local A=$( echo -n "$EXPECTED" | jq --compact-output --sort-keys . )
  local B=$( echo -n "$ACTUAL"   | jq --compact-output --sort-keys . )

  assert_equal "$A" "$B"
}

##
# Assert that a command was successful, and its output is JSON
#
# Usage:
#   assert_success_json # no input? test $output
#   assert_success_json '[1]'
#
function assert_success_json() {
  assert_success
  assert_json_equal "$1"
}

##
# Assert that a command was not successful, and its output is JSON
#
# Usage:
#   assert_failure_json # no input? test $output
#   assert_failure_json '[1]'
#
function assert_failure_json() {
  assert_failure
  assert_json_equal "$1"
}

##
# Assert that a JSON object contains some key
#
# Usage:
#   assert_json_key foo '{ "foo": 1 }'
#
function assert_json_key() {
  local KEY="$1"
  local VALUE="$2"
  local JSON="${3:-$output}"

  if ! __json_has_key "$KEY" "$JSON"; then
    flunk "JSON should have a \"$KEY\" key, but does not: $JSON"
  elif [[ "$VALUE" != "" ]]; then
    assert_json_equal "$VALUE" "$(echo "$JSON" | jq --arg key "$KEY" '.[$key]')"
  else
    true
  fi
}

##
# Assert that a JSON object does not contain some key
#
# Usage:
#   assert_json_key foo '{ "foo": 1 }'
#
function refute_json_key() {
  local KEY="$1"
  local JSON="${2:-$output}"

  if __json_has_key "$KEY" "$JSON"; then
    flunk "JSON has a \"$KEY\" key, but should not: $JSON"
  else
    true
  fi
}
