##
# Library of json-related bash functions
#

__require_dependencies jq

##
# Convert a JSON array to a list of newline-separated strings
#
# Usage: '<json array>' | __from_json_array
#
# See also: __to_json_array()
#
# Examples:
#   echo '["foo","bar"]' | __from_json_array # => "foo\nbar"
#
function __from_json_array() {
  local INPUT="$(cat -)"

  echo "$INPUT" |
  jq --raw-output 'map( select( ( . // "" ) != "" ) ) | .[]' 2>/dev/null
}

##
# Test whether a string is valid JSON
#
# Usage: __is_json <string>
#
# Examples:
#   __is_json '[1,2,3]' # => 0
#   __is_json 'asdf'    # => 1
#
function __is_json() {
  [[ "$1" != "" ]] &&
  echo "$1" | jq . >/dev/null 2>&1 &&
  true
}

##
# A 'jq' wrapper which includes our extra functions. See: stdlib.jq
#
# Usage: __jq <jq args>
#
# Examples:
#   echo '{}' | __jq .
#
function __jq() {
  # shellcheck disable=SC2124
  local LAST="${@: -1:1}"

  set -- "${@:1:$(($#-1))}" -L "${_RIV_ROOT}/share/riv/lib" "include \"stdlib\"; ${LAST}"

  TZ=UTC jq --compact-output --monochrome-output "$@"
}

##
# Combine like JSON objects
#
# See: https://stedolan.github.io/jq/manual/#Addition:+
#
# Usage: __json_merge <json...>
#
# Examples:
#   __json_merge '[1]' '[2]' '[3]'     # => [1,2,3]
#   __json_merge '{ x: 1 }' '{ y: 2 }' # => { x: 1, y: 2 }
#
function __json_merge() {
  [[ "$*" == "" ]] && return 1

  local ARR="$1"; shift

  for I in "$@"; do
    ARR="$(echo "$ARR" | jq --argjson i "$I" '. + $i')"
  done

  echo "$ARR" | jq --compact-output --monochrome-output .
}

##
# Extrack the given path from each object in a JSON array
#
# Usage: <json array of objects> | __json_pluck <key>
#
# Examples:
#   '[{"id": 1}, {"id": 2}]' | __json_pluck id # => [1,2]
#
function __json_pluck() {
  [[ "$#" != "1" ]] && return 1

  cat - | __json_select -j "$1" null
}

##
# Select a value from JSON object with a simple path string
#
# Usage: <json object> | __json_select <json path> [default]
#
# Examples:
#   echo '{"foo":{"bar":true}} | __json_select foo/bar # => true
#   echo '{"foo":{"bar":true}} | __json_select x       # => null
#   echo '{"foo":{"bar":true}} | __json_select x foo   # => "foo"
#
function __json_select() {
  local PATH_SELECTOR=
  local RAW_OPT="--raw-output"
  local DEFAULT=""

  function _parse_options() {
    local OPTIND=0

    while getopts ":j" OPT; do
      case $OPT in
        j) RAW_OPT="";;
        *) return 1;;
      esac
    done

    shift $((OPTIND - 1))

    PATH_SELECTOR="$1"
    DEFAULT="$2"
  }

  _parse_options "$@"

  # shellcheck disable=SC2016
  cat - | __jq $RAW_OPT --arg path "$PATH_SELECTOR" --arg default "$DEFAULT" '
    def __select_and_coerce( path ):
      __select($path) | if . == null then ($default | __coerce) else . end
    ;

    if type == "array" then
      map(__select_and_coerce($path))
    else
      __select_and_coerce($path)
    end
  '
}

##
# Convert a JSON string to an equivalent YAML string
#
# Usage: <json> | __json_to_yaml
#
# Examples:
#   echo '{"foo":[1,2]}' | __json_to_yaml # => '---\nfoo:\n- 1\n- 2'
#
function __json_to_yaml() {
  echo "---"
  python3 -c 'import sys, json, ruamel.yaml as Y; Y.YAML().dump(json.load(sys.stdin), sys.stdout)'
}

##
# Convert input lines to a JSON array of strings
#
# Usage: <string> | to_json_array
#
# See also: __from_json_array()
#
# Examples:
#   echo -e "foo\nbar" | __to_json_array # => ["foo","bar"]
#
function __to_json_array() {
  local INPUT="$(cat -)"

  echo -n "$INPUT" | jq --compact-output --monochrome-output \
    --raw-input --slurp 'split("\n")'
}

##
# Convert YAML to JSON
#
# Usage: <yaml> | __yaml_to_json
#
# Examples:
#   echo -e '---\nfoo: "bar"' | __yaml_to_json() # => '{"foo":"bar"}'
#
function __yaml_to_json() {
  python3 -c 'import sys, json, ruamel.yaml as Y; print(json.dumps(Y.YAML(typ="safe").load(sys.stdin)))' |
  jq --compact-output .
}
