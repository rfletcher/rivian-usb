##
# Standard library of input validation bash functions
#

##
# Verify that a string is in the form of a valid hostname, or exit
#
# Usage: __validate_as_hostname <name> [error]
#
# Examples:
#   __validate_as_hostname "Role"
#
function __validate_as_hostname() {
  local VALUE="$1"
  local NAME="${2:-Value}"

  if [[ "$VALUE" != "" ]]; then
    [[ "$VALUE" =~ ^[0-9A-Za-z-]+$ ]] || __die "${NAME} can only contain a-z, 0-9 and hyphens: \"${VALUE}\""
  fi
}

##
# Verify that only one of a list of values is present
#
# Usage: __validate_exclusive <value...>
#
# Examples:
#   __validate_exclusive "1" "" ""  # => success
#   __validate_exclusive "1" "" "2" # => failure
#
function __validate_exclusive() {
  local FOUND=0

  for I in "$@"; do
    if [[ "$I" != "" ]]; then
      if [[ "$FOUND" == "0" ]]; then
        FOUND=1
      else
        return 1
      fi
    fi
  done
}

##
# Verify that a string's value is a positive integer
#
# Usage: __validate_integer <value> [error]
#
# Examples:
#   __validate_integer "1"
#
function __validate_integer() {
  local VALUE="$1"
  local ERROR="${2:-Value must be an integer}"

  [[ "$VALUE" =~ ^[0-9]+$ ]] || __die "$ERROR"
}

##
# Verify that a string is valid JSON
#
# Usage: __validate_json <json> [type]
#
# Examples:
#   __validate_json "[]"
#   __validate_json "[]" object # optionally specify a type
#
function __validate_json() {
  local VALUE="$1"
  local TYPE_WANTED="$2"

  if ! __is_json "$VALUE"; then
    __die "Value is not JSON: $VALUE"
  fi

  if [[ "$TYPE_WANTED" != "" ]]; then
    local TYPE_FOUND=$(echo "$VALUE" | jq --raw-output '. | type' 2>/dev/null)

    if [[ "$TYPE_WANTED" != "$TYPE_FOUND" ]]; then
      __die "Expected JSON ${TYPE_WANTED}, got ${TYPE_FOUND}: $VALUE"
    fi
  fi
}

##
# Verify that a string does not contain bash expansion
#
# Usage: __validate_no_expansion <value> [name]
#
# Examples:
#   __validate_no_expansion "api-{1..5}"
#
function __validate_no_expansion() {
  local VALUE="$1"
  local NAME="${2:-Value}"

  if [[ "$VALUE" != "" ]]; then
    [[ "$(__expand "${VALUE}")" == "${VALUE}" ]] || __die "${NAME} cannot include expansion: \"${VALUE}\""
  fi
}

##
# Verify that a string is not empty
#
# Usage: __validate_present <value> [error]
#
# Examples:
#   __validate_present ""
#
function __validate_present() {
  local VALUE="$1"
  local ERROR="${2:-Value cannot be empty}"

  [[ "$VALUE" != "" ]] || __die "$ERROR"
}

##
# Verify that a string has just one line
#
# Usage: __validate_single_value <value> [error too few] [error too many]
#
# Examples:
#   __validate_single_value "value"
#
function __validate_single_value() {
  local VALUE="$1"
  local ERROR_NONE="$3"
  local ERROR_MANY="$4"

  _validate_present "$VALUE" "$ERROR_NONE"

  if [[ $(echo "$VALUE" | wc -l) -gt 1 ]]; then
    __die "$ERROR_MANY"
  fi
}
