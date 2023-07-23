##
# riv standard library of bash functions and aliases
#

##
# Ask the user to confirm whether they'd like to proceed
#
# Usage:
#   _confirm "Really do the thing?" && do_the_thing
#
function _confirm() {
  local RESPONSE
  local MESSAGE="${1:-Proceed?}"

  _say -n "$MESSAGE (y/n): "

  while true; do
    read -r RESPONSE

    if [[ "$RESPONSE" == "y"   ]] ||
       [[ "$RESPONSE" == "n"   ]] ||
       [[ "$RESPONSE" == "yes" ]] ||
       [[ "$RESPONSE" == "no"  ]]; then
      break
    else
      _say -n "Please enter 'y' or 'n': "
    fi
  done

  [[ "$RESPONSE" == "y" ]] || [[ "$RESPONSE" == "yes" ]]; return
}

##
# Print an error message and quit
#
# Usage:
#   _die "uh oh"
#
function _die() {
  _error "$@"

  exit 1
}

##
# Print an error message
#
# Usage:
#   _error "uh oh"
#
function _error() {
  local OPTS=

  if [[ "$1" =~ ^- ]]; then
    OPTS="$1"; shift
  fi

  # shellcheck disable=SC2086 # $OPTS might be blank, and we don't want to pass an empty string
  _say $OPTS "Error: $*" 1>&2

  return 1
}

##
# Evaluate a bash expansion
#
# Usage:
#   _expand "{1..5}"
#
function _expand() {
  [[ "$*" == "" ]] && return

  # shellcheck disable=SC2294
  eval echo -n "$@"
}

##
# Convert a JSON array to a raw list of lines
#
# Usage:
#  echo '["foo","bar"]' | _from_json_array # => "foo\nbar"
#
function _from_json_array() {
  local INPUT="$(cat -)"

  echo "$INPUT" |
  jq --raw-output 'map( select( ( . // "" ) != "" ) ) | .[]' 2>/dev/null
}

##
# Print or execute some command, depending on whether this is a dry run
#
# Usage:
#   _if_not_dry_run 1 echo "foo"  => (the echo command is printed, not executed)
#   _if_not_dry_run "" echo "foo" => "foo"
#
function _if_not_dry_run() {
  local DRY_RUN="$1"; shift

  if [[ "$DRY_RUN" == "1" ]]; then
    _say "This is a dry run. If it was not, we would have run this command:"

    echo -ne "\t"
    printf "%q " "$@"
    echo
  else
    "$@"
  fi
}

##
# Test whether a value exists in an array
#
# Usage:
#  HAYSTACK=( foo bar ) _in_array needle "${HAYSTACK[@]" # => 0
#  HAYSTACK=( foo bar ) _in_array foo "${HAYSTACK[@]" # => 1
#
function _in_array() {
  local I
  local NEEDLE="$1"; shift

  for ITEM; do
    [[ "$ITEM" == "$NEEDLE" ]] && return 0
  done

  return 1
}

##
# Test whether a string is valid JSON
#
# Usage:
#   _is_json '[1,2,3]' # => 0
#   _is_json 'asdf'    # => 1
#
function _is_json() {
  [[ "$1" != "" ]] &&
  echo "$1" | jq . >/dev/null 2>&1 &&
  true
}

##
# Test whether we're running in Kubernetes
#
# Usage: _is_kubernetes
#
function _is_kubernetes() {
  [[ "$KUBERNETES_SERVICE_HOST" != "" ]]
}

##
# Test whether a string is the form of an IP address
#
# Usage:
#   _is_ip "1.2.3.4"
#
function _is_ip() {
  local VALUE="$1"

  [[ "$VALUE" =~ ^([[:digit:]]{1,3}\.){3}[[:digit:]]{1,3}$ ]]
}

##
# Test whether a mount is read-only
#
# Usage:
#   _is_readonly_mount /boot
#
function _is_readonly_mount() {
  # shellcheck disable=SC2016 # shellcheck doesn't know these are awk vars
  $(type -p gawk awk | head -1) '
    $4~/(^|,)ro($|,)/ {
      print $2
    }' /proc/mounts |
  grep -Fqx "$1"
}

##
# Test whether a file/dir is on a read-only mount
#
# Usage:
#   _is_readonly_path /home/jdoe
#
function _is_readonly_path() {
  _is_readonly_mount "$(_path_to_mount "$1")"
}

##
# Test whether a string is the form of a URL
#
# Usage:
#   _is_url "http://example.com"
#
function _is_url() {
  local VALUE="$1"

  [[ "$VALUE" =~ ^[^:]+://.+ ]]
}

##
# Join tokens
#
# Usage:
#  _join , a "b c" d                  # => "a,b c,d"
#  _join / "" var log                 # => "/var/log"
#  FOO=( a b c ); _join , "${FOO[@]}" # => "a,b,c"
#
function _join() {
  [[ "$*" == "" ]] && return 1

  local IFS="$1";
  shift
  echo "$*"
}

##
# Combine like JSON objects
# See: https://stedolan.github.io/jq/manual/#Addition-`+`
#
# Usage:
#  _json_merge '[1]' '[2]' '[3]'     # => [1,2,3]
#  _json_merge '{ x: 1 }' '{ y: 2 }' # => { x: 1, y: 2 }
#
function _json_merge() {
  [[ "$*" == "" ]] && return 1

  local ARR="$1"; shift

  for I in "$@"; do
    ARR="$(echo "$ARR" | jq --argjson i "$I" '. + $i')"
  done

  echo "$ARR" | jq --compact-output --monochrome-output .
}

##
# Partially obscure the value of a string, e.g. to protect a secret before display
#
# Usage:
#   _mask_secret "my password" # => "********ord"
#
function _mask_secret() {
  local VALUE="$1"
  local LEN="${#VALUE}"
  local MASK="********************"

  if (( "$LEN" <= 3 )); then
    local MASKED="$MASK"
  else
    if (( "$LEN" <= "4" )); then
      local SUFFIX_LEN=$((LEN / 4))
    else
      local SUFFIX_LEN=$(((LEN + 2) / 4))
    fi
    SUFFIX_LEN=$(_min 4 $SUFFIX_LEN)

    local MASKED="${MASK}${VALUE: -${SUFFIX_LEN}}"
  fi

  echo "${MASKED: -${#MASK}}"
}

##
# Get the highest value from a list of numbers
#
# Usage:
#   _max 100 30.49 6 4,000 # => 4000
#
function _max() {
  [[ "$*" == "" ]] && return 1

  printf '%s\n' "$@" | sed 's/[^0-9.]//g; /^$/ d' | sort -nr | head -1
}

##
# Get the lowest value from a list of numbers
#
# Usage:
#   _min 100 30.49 6 4,000 # => 6
#
function _min() {
  [[ "$*" == "" ]] && return 1

  printf '%s\n' "$@" | sed 's/[^0-9.]//g; /^$/ d' | sort -n | head -1
}

##
# Get the mount point containing some path
#
# Usage:
#   _path_to_mount /home/jdoe # => /
#
function _path_to_mount() {
  findmnt --canonicalize --output TARGET --noheadings  --target "$1"
}

##
# Pick the first non-empty value in a list
#
# Usage:
#  _pick "$(foo)" "$bar" "default" # => default
#
function _pick() {
  for I in "$@"; do
    if [[ "$I" != "" ]]; then
      echo "$I"
      return
    fi
  done

  return 1
}

##
# Prompt for a value from stdin, saving input to an ENV variable
#
# Usage:
#  _prompt_for_var "Name" "FIRST_NAME"
#     # => prompt:   "Name: "
#     # => input:    Bob
#     # => variable: FIRST_NAME=Bob
#  _prompt_for_var "API Key" "MY_API_KEY" "abcd7890" 1
#     # => prompt:   API Key [******90]:
#     # => input:    (none)
#     # => variable: MY_API_KEY=abcd7890
#
function _prompt_for_var() {
  local NAME="$1"
  local VAR="$2"
  local DEFAULT="$3"
  local SECRET="$4"

  local INPUT

  if [[ "$DEFAULT" != "" ]]; then
    if [[ "$SECRET" == "1" ]]; then
      DEFAULT=$(_mask_secret "$DEFAULT")
    fi

    NAME="${NAME} [${DEFAULT}]"
  fi

  echo -n "Cloudflare ${NAME}: "
  read -r INPUT

  if [[ "$INPUT" != "" ]]; then
    eval "${VAR}"="${INPUT}"
  fi
}

##
# Translate an exit status to English
#
# Usage:
#   _say "Running some command..."
#   some_command_that_might_have_worked
#   _report_result "$?"
#
function _report_result() {
  local STATUS="${1:-1}"

  if [[ "$STATUS" != "0" ]]; then
    _say "Error"
  else
    _say "Done"
  fi

  return "$STATUS"
}

##
# Ensure external dependencies are installed
#
# Usage:
#   _require_dependencies aws jq ls
#
function _require_dependencies() {
  [[ "$*" == "" ]] && return 1

  local MISSING=()

  for DEPENDENCY in "$@"; do
    if ! type -p "$DEPENDENCY" >/dev/null 2>&1; then
      MISSING=( "${MISSING[@]}" "$DEPENDENCY" )
    fi
  done

  if [[ "${#MISSING[@]}" -gt 0 ]]; then
    _die "This script has missing dependencies: ${MISSING[*]}"
  fi

  return 0
}

##
# Ensure a shared library/libraries is loaded
#
# Usage:
#   _require_lib check
#
function _require_lib() {
  [[ "$*" == "" ]] && return 1

  local MISSING=()

  for LIB in "$@"; do
    local LIB_PATH="${_RIV_SHARE}/riv-${LIB}.bash"

    if test -f "$LIB_PATH"; then
      # shellcheck disable=SC1090
      source "$LIB_PATH" || exit 1
    else
      MISSING=( "${MISSING[@]}" "$LIB" )
    fi
  done

  if [[ "${#MISSING[@]}" -gt 0 ]]; then
    _die "This script requires missing libraries: ${MISSING[*]}"
  fi

  return 0
}

##
# Echo, with a timestamp
#
# Usage:
#   _say "here's a message"
#
function _say() {
  local ECHO="echo -e"
  local TIMESTAMP=$(date --rfc-3339=seconds 2>/dev/null || date)

  if [[ "$1" =~ ^- ]]; then
    ECHO="echo $1"; shift
  fi

   $ECHO "${TIMESTAMP}: ${_RIV_COMMAND}:" "$@"
}

##
# Remove extra indentation from each line of a string
#
# Usage:
#   cat <<EOT | _strip_heredoc | ...
#     foo
#   EOT
#
function _strip_heredoc() {
  local INPUT="$(cat -)"
  local INDENT="$1"

  local LEAST_INDENTED="$(echo "$INPUT" | sort | tail -1)"
  local NEW_PREFIX=
  local PREFIX="${LEAST_INDENTED/[^[:space:]]/.}"
  PREFIX="${PREFIX%%.*}"

  if [[ "$INDENT" != "" ]]; then
    NEW_PREFIX="$(printf ' %.0s' $(seq 1 "$INDENT"))"
  fi

  if [[ "$PREFIX" == "" ]]; then
    echo "${NEW_PREFIX}${INPUT}"
  else
    # shellcheck disable=SC2001 # we're doing multiple substitutions happening
    echo "$INPUT" | sed "s/^${PREFIX}/${NEW_PREFIX}/"
  fi
}

##
# Convert input lines to a JSON array of strings
#
# Usage:
#  echo -e "foo\nbar" | _to_json_array # => ["foo","bar"]
#
function _to_json_array() {
  local INPUT="$(cat -)"

  echo -n "$INPUT" | jq --compact-output --monochrome-output \
    --raw-input --slurp 'split("\n")'
}

##
# Create a temporary directory
#
# Usage:
#  TMPDIR=$(_tmpdir); echo foo > $TMPDIR/foo.txt
#
function _tmpdir() {
  mktemp -d riv.XXXX
}

##
# Convert input to lower case
#
# Usage:
#  echo "A Value" | _to_lower # => a value
#
function _to_lower() {
  cat - | tr '[:upper:] [:lower:]'
}

##
# Reformat a string such that it's safe for use as an ENV variable name
#
# Usage:
#  echo -e "Some\tString!  " | _to_var_name # => "SOME_STRING"
#
function _to_var_name() {
  local INPUT=$(cat -)

  # shellcheck disable=SC2060
  local OUTPUT=$(echo -n "$INPUT"  |
    tr '[:lower:]' '[:upper:]'       | # convert to uppercase
    tr -Cd [A-Z][0-9]'[:space:]._/-' | # limit to certain characters
    tr -C [A-Z][0-9] _               | # convert separators to underscores
    sed "s/^[0-9_]*//; s/_*\$//"     | # trim invalid/unwanted leading/trailing chars
    sed "s/__*/_/g"                    # collapse runs of underscores
  )

  if [[ "$OUTPUT" == "" ]]; then
    echo "_"
  else
    echo "$OUTPUT"
  fi
}

##
# Trim leading and trailing whitespace
#
# Usage:
#   _trim " foo bar  " # => "foo bar"
#
function _trim() {
  echo "$1" | sed -e 's/^[[:space:]]*//' | sed -e 's/[[:space:]]*$//'
}

##
# Verify that a string is in the form of a valid hostname, or exit
#
# Usage:
#   _validate_as_hostname "Role" "asdf-123"
#
function _validate_as_hostname() {
  local VALUE="$1"
  local NAME="${2:-Value}"

  if [[ "$VALUE" != "" ]]; then
    [[ "$VALUE" =~ ^[0-9A-Za-z-]+$ ]] || _die "${NAME} can only contain a-z, 0-9 and hyphens: \"${VALUE}\""
  fi
}

##
# Verify that only one of a list of values is present
#
# Usage:
#   _validate_exclusive "1" "" ""  # => success
#   _validate_exclusive "1" "" "2" # => failure
#
function _validate_exclusive() {
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
# Usage:
#   _validate_integer "1"
#
function _validate_integer() {
  local VALUE="$1"
  local ERROR="${2:-Value must be an integer}"

  [[ "$VALUE" =~ ^[0-9]+$ ]] || _die "$ERROR"
}

##
# Verify that a string is valid JSON
#
# Usage:
#   _validate_json "[]"
#   _validate_json "[]" object # optionally specify a type
#
function _validate_json() {
  local VALUE="$1"
  local TYPE_WANTED="$2"

  if ! _is_json "$VALUE"; then
    _die "Value is not JSON: $VALUE"
  fi

  if [[ "$TYPE_WANTED" != "" ]]; then
    local TYPE_FOUND=$(echo "$VALUE" | jq --raw-output '. | type' 2>/dev/null)

    if [[ "$TYPE_WANTED" != "$TYPE_FOUND" ]]; then
      _die "Expected JSON ${TYPE_WANTED}, got ${TYPE_FOUND}: $VALUE"
    fi
  fi
}

##
# Verify that a string does not contain bash expansion
#
# Usage:
#   _validate_no_expansion "api-{1..5}"
#
function _validate_no_expansion() {
  local VALUE="$1"
  local NAME="${2:-Value}"

  if [[ "$VALUE" != "" ]]; then
    [[ "$(_expand "${VALUE}")" == "${VALUE}" ]] || _die "${NAME} cannot include expansion: \"${VALUE}\""
  fi
}

##
# Verify that a string is not empty
#
# Usage:
#   _validate_present ""
#
function _validate_present() {
  local VALUE="$1"
  local ERROR="${2:-Value cannot be empty}"

  [[ "$VALUE" != "" ]] || _die "$ERROR"
}

##
# Verify that a string has just one line
#
# Usage:
#   _validate_single_value "value"
#
function _validate_single_value() {
  local VALUE="$1"
  local ERROR_NONE="$3"
  local ERROR_MANY="$4"

  _validate_present "$VALUE" "$ERROR_NONE"

  if [[ $(echo "$VALUE" | wc -l) -gt 1 ]]; then
    _die "$ERROR_MANY"
  fi
}

##
# Repeatedly execute some command, stopping when it executes successfully
#
# Usage:
#   Wait for a command to work:
#     _wait_for "date | grep -q 'Tues'"
#   ...checking once/minute:
#     _wait_for "date | grep -q 'Tues'" 60
#   ...with a custom status message:
#     _wait_for "date | grep -q 'Tues'" 60 "Waiting until Tuesday..."
#   ...timing out after a day:
#     _wait_for "date | grep -q 'Tues'" 60 "Waiting until Tuesday..." 86400
#
function _wait_for() {
  [[ "$*" == "" ]] && return 1

  local CMD="$1"
  local SLEEP="${2:-5}"
  local MESSAGE="${3:-.}"
  local TIMEOUT="$4"

  local START="$(date +%s)"

  [[ "$MESSAGE" != "." ]] && _say "$MESSAGE"

  while ! eval "$CMD" >/dev/null; do
    if [[ "$TIMEOUT" != "" ]]; then
      local NOW="$(date +%s)"
      local ELAPSED="$((NOW - START))"
      local REMAINING="$((TIMEOUT - ELAPSED))"

      if [[ "$TIMEOUT" != "" ]] && [[ "$ELAPSED" -ge "$TIMEOUT" ]]; then
        if [[ "$MESSAGE" == "." ]]; then
          echo
        fi

        return 1
      fi

      if [[ "$REMAINING" -lt "$SLEEP" ]]; then
        SLEEP=$REMAINING
      fi
    fi

    sleep "$SLEEP"

    if [[ "$MESSAGE" == "." ]]; then
      echo -n "$MESSAGE"
    else
      _say "$MESSAGE"
    fi
  done

  [[ "$MESSAGE" == "." ]] && echo

  return 0
}

if [[ "$RIV_DEBUG" == "1" ]]; then
  set -x
fi