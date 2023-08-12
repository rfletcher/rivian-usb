##
# riv standard library of bash functions and aliases
#

##
# Ask the user to confirm whether they'd like to proceed
#
# Usage:
#   __confirm "Really do the thing?" && do_the_thing
#
function __confirm() {
  local RESPONSE
  local MESSAGE="${1:-Proceed?}"

  __say -n "$MESSAGE (y/n): "

  while true; do
    read -r RESPONSE

    if [[ "$RESPONSE" == "y"   ]] ||
       [[ "$RESPONSE" == "n"   ]] ||
       [[ "$RESPONSE" == "yes" ]] ||
       [[ "$RESPONSE" == "no"  ]]; then
      break
    else
      __say -n "Please enter 'y' or 'n': "
    fi
  done

  [[ "$RESPONSE" == "y" ]] || [[ "$RESPONSE" == "yes" ]]; return
}

##
# Print an error message and quit
#
# Usage: __die [message]
#
# Examples:
#   __die "uh oh"
#
function __die() {
  [[ "$1" == "" ]] || __error "$@"
  __exit 1
}

##
# Print an error message
#
# Usage: __error [message]
#
# Examples:
#   __error "uh oh"
#
function __error() {
  local OPTS=

  if [[ "$1" =~ ^- ]]; then
    OPTS="$1"; shift
  fi

  __say $OPTS "Error: $@" 1>&2

  return 1
}

##
# Exit the shell without running any EXIT handler
#
# Usage: __exit [status]
#
# Examples:
#   __exit 1
#
function __exit() {
  trap - EXIT
  exit "$@"
}

##
# Evaluate a bash expansion
#
# Usage:
#   __expand "{1..5}"
#
function __expand() {
  [[ "$*" == "" ]] && return

  # shellcheck disable=SC2294
  eval echo -n "$@"
}

##
# Get the mount point containing some path
#
# Usage:
#   __find_mount /home/jdoe # => /
#
function __find_mount() {
  [[ "$#" == "1" ]] || return 1

  findmnt --canonicalize --output TARGET --noheadings  --target "$1"
}

##
# Test whether a function is defined
#
# Usage: __function_exists <name>
#
# Examples:
#   __function_exists main # => true
#
function __function_exists() {
  declare -F "$1" &>/dev/null
}

##
# Print or execute some command, depending on whether this is a dry run
#
# Usage: __if_not_dry_run <dry_run> <command...>
#
# Examples:
#   __if_not_dry_run 1 echo "foo"  # => echo "foo"
#   __if_not_dry_run "" echo "foo" # => "foo"
#
function __if_not_dry_run() {
  local DRY_RUN=
  local INDENT=
  local CMD=

  function _parse_options() {
    local OPTIND=0

    while getopts ":i" opt; do
      case $opt in
        i) INDENT=1;;
      esac
    done

    shift $((OPTIND - 1))

    DRY_RUN="$1"; shift
    CMD=( "$@" )
  }

  _parse_options "$@"

  if [[ "$DRY_RUN" == "1" ]]; then
    __say "This is a dry run (-n), but we *would* have run this command:" >&2

    local SED_BIN=$(which gsed || which sed)
    { printf "%q " "${CMD[@]}" | $SED_BIN 's/ $//'; echo; } | __indent >&2
  elif [[ "$INDENT" == "1" ]]; then
    "${CMD[@]}" 2>&1 | __indent
  else
    "${CMD[@]}"
  fi
}

##
# Test whether a value exists in an array
#
# Usage:
#  HAYSTACK=( foo bar ) __in_array needle "${HAYSTACK[@]" # => 0
#  HAYSTACK=( foo bar ) __in_array foo "${HAYSTACK[@]" # => 1
#
function __in_array() {
  local I
  local NEEDLE="$1"; shift

  for ITEM; do
    [[ "$ITEM" == "$NEEDLE" ]] && return 0
  done

  return 1
}

##
# Manage indentation for __say output
#
# Usage: __increase_indent
#
# Examples: __say foo; __increase_indent; __say bar
#
function __increase_indent() { _RIV_INDENT=$(__max 0 $((_RIV_INDENT + 2))); }
function __decrease_indent() { _RIV_INDENT=$(__max 0 $((_RIV_INDENT - 2))); }
function __reset_indent()    { _RIV_INDENT=0; }

##
# Indent lines of text with spaces
#
# Usage: ... | __indent [width]
#
# Examples:
#   echo -e 'foo\nbar' | __indent 4 # => "    foo\n    bar"
#
function __indent() {
  local WIDTH="${1:-2}"
  local PREFIX=$(printf ' %.0s' $(seq 1 $WIDTH))

  local OLDIFS="$IFS";  IFS=
  cat - | while read -r LINE; do
    echo -n "$PREFIX"; echo "$LINE"
  done
  IFS="$OLDIFS"
}

##
# Test whether a string is the form of an IP address
#
# Usage:
#   __is_ip "1.2.3.4"
#
function __is_ip() {
  local VALUE="$1"

  [[ "$VALUE" =~ ^([[:digit:]]{1,3}\.){3}[[:digit:]]{1,3}$ ]]
}

##
# Test whether a mount is read-only
#
# Usage:
#   __is_readonly_mount /boot
#
function __is_readonly_mount() {
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
#   __is_readonly_path /home/jdoe
#
function __is_readonly_path() {
  __is_readonly_mount "$(__path_to_mount "$1")"
}

##
# Test whether we're running on a "single-board computer" (raspberry pi, etc.)
#
function __is_sbc() {
  local MODEL=/sys/firmware/devicetree/base/model

  test -f "$MODEL" &&
  grep -qE "raspbery pi|rock pi|radxa zero" "$MODEL"
}

##
# Test whether we're running as a background service
#
# Usage:
#   __is_systemd_service
#
function __is_systemd_service() {
  [[ "$INVOCATION_ID" != "" ]]
}

##
# Test whether a string is the form of a URL
#
# Usage:
#   __is_url "http://example.com"
#
function __is_url() {
  local VALUE="$1"

  [[ "$VALUE" =~ ^[^:]+://.+ ]]
}

##
# Join strings together with some delimiter
#
# Usage:
#   __join <delimiter> <value...>
#   <multiline string> | __join <delimiter>
#
# Examples:
#   __join , a "b c" d                   # => "a,b c,d"
#   __join / "" var log                  # => "/var/log"
#   FOO=( a b c ); __join , "${FOO[@]}"  # => "a,b,c"
#   echo -e 'foo bar\nbaz' | __join ', ' #=> "foo bar, baz"
#
function __join() {
  [[ "$#" == "0" ]] && return 1

  if [[ "$#" == "1" ]]; then
    local LINES=
    mapfile -t LINES
    set -- "$1" "${LINES[@]}"
  fi

  local DELIMITER=${1-}
  local FIRST=${2-}

  if shift 2; then
    printf %s "$FIRST" "${@/#/$DELIMITER}"
  fi
}

##
# Pad a string to an arbitrary length, and left/right/center the original value
#
# Usage: __justify <layout> <value>
#
# Examples:
#   # pad to 4 characters; right align (the default)
#   __justify "4" "xy"   # => "  xy"
#   # pad to 5 characters; left align
#   __justify "5-" "xy"  # => "xy   "
#   # pad to 6 characters; center align
#   __justify "-6-" "xy" # => "  xy  "
#
function __justify() {
  [[ "$#" == "2" ]] || return 1

  local WIDTH="$1"
  local VALUE="$2";

  function _with_padding() {
    local WIDTH="$1"
    local VALUE="$2"
    local MODIFIER=

    if [[ "$WIDTH" == -* ]]; then
      MODIFIER="-"
      WIDTH="${WIDTH#-}"
    fi

    local BYTES=$(printf '%s' "$VALUE" | wc -c)
    local CHARS=$(printf '%s' "$VALUE" | wc -m)
    local UNICODE_ADJUSTMENT=$(( BYTES - CHARS ))

    printf "%${MODIFIER}$(( ${WIDTH} + UNICODE_ADJUSTMENT ))s" "$VALUE"
  }

  # to figure out display width (unicode support)
  local VALUE_WIDTH=${#VALUE}

  # center justify
  if [[ "$WIDTH" == -*- ]]; then
    WIDTH=${WIDTH#-}
    WIDTH=${WIDTH%-}

    if [[ "$VALUE_WIDTH" -lt 2 ]]; then
      local LVALUE=""
      local RVALUE="$VALUE"
    else
      local LVALUE="$(echo "$VALUE" | cut -c 1-$(( ${VALUE_WIDTH} / 2 )))"
      local RVALUE="$(echo "$VALUE" | cut -c $(( ${VALUE_WIDTH} / 2 + 1 ))-${VALUE_WIDTH})"
    fi
    local LWIDTH=$(( WIDTH / 2 ))
    local RWIDTH=$(( WIDTH / 2 ))

    if [[ $(( LWIDTH + RWIDTH )) -lt $WIDTH ]]; then
      RWIDTH=$(( RWIDTH + 1 ))
    fi

    _with_padding "$LWIDTH" "$LVALUE"
    _with_padding "-${RWIDTH}" "$RVALUE"
  # right justify
  elif [[ "$WIDTH" == *- ]]; then
    _with_padding "${WIDTH%-}" "$VALUE"
  # left justify
  else
    _with_padding "-${WIDTH#-}" "$VALUE"
  fi
}

##
# Combine like JSON objects
# See: https://stedolan.github.io/jq/manual/#Addition-`+`
#
# Usage:
#  __json_merge '[1]' '[2]' '[3]'     # => [1,2,3]
#  __json_merge '{ x: 1 }' '{ y: 2 }' # => { x: 1, y: 2 }
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
# Partially obscure the value of a string, e.g. to protect a secret before display
#
# Usage:
#   __mask_secret "my password" # => "********ord"
#
function __mask_secret() {
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
    SUFFIX_LEN=$(__min 4 $SUFFIX_LEN)

    local MASKED="${MASK}${VALUE: -${SUFFIX_LEN}}"
  fi

  echo "${MASKED: -${#MASK}}"
}

##
# Get the highest value from a list of numbers
#
# Usage:
#   __max 100 30.49 6 4,000 # => 4000
#
function __max() {
  [[ "$*" == "" ]] && return 1

  printf '%s\n' "$@" | sed 's/[^0-9.]//g; /^$/ d' | sort -nr | head -1
}

##
# Get the lowest value from a list of numbers
#
# Usage:
#   __min 100 30.49 6 4,000 # => 6
#
function __min() {
  [[ "$*" == "" ]] && return 1

  printf '%s\n' "$@" | sed 's/[^0-9.]//g; /^$/ d' | sort -n | head -1
}

##
# Pad a string with spaces on each side
#
# Usage: __pad <width> <value>
#
# Examples:
#   __pad 2 "foo" # => "  foo  "
#
function __pad() {
  [[ "$#" == "2" ]] || return 1

  local WIDTH="$1"
  local VALUE="$2"

  printf "%${WIDTH}s%s%${WIDTH}s" "" "$VALUE" ""
}

##
# Pick the first non-empty value in a list
#
# Usage:
#  __pick "$(foo)" "$bar" "default" # => default
#
function __pick() {
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
#  __prompt_for_var "Name" "FIRST_NAME"
#     # => prompt:   "Name: "
#     # => input:    Bob
#     # => variable: FIRST_NAME=Bob
#  __prompt_for_var "API Key" "MY_API_KEY" "abcd7890" 1
#     # => prompt:   API Key [******90]:
#     # => input:    (none)
#     # => variable: MY_API_KEY=abcd7890
#
function __prompt_for_var() {
  local NAME="$1"
  local VAR="$2"
  local DEFAULT="$3"
  local SECRET="$4"

  local INPUT

  if [[ "$DEFAULT" != "" ]]; then
    if [[ "$SECRET" == "1" ]]; then
      DEFAULT=$(__mask_secret "$DEFAULT")
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
#   __say "Running some command..."
#   some_command_that_might_have_worked
#   __report_result "$?"
#
function __report_result() {
  local STATUS="${1:-1}"

  if [[ "$STATUS" != "0" ]]; then
    __say "Error"
  else
    __say "Done"
  fi

  return "$STATUS"
}

##
# Ensure external dependencies are installed
#
# Usage:
#   __require_dependencies aws jq ls
#
function __require_dependencies() {
  [[ "$*" == "" ]] && return 1

  local MISSING=()

  for DEPENDENCY in "$@"; do
    if ! type -p "$DEPENDENCY" >/dev/null 2>&1; then
      MISSING=( "${MISSING[@]}" "$DEPENDENCY" )
    fi
  done

  if [[ "${#MISSING[@]}" -gt 0 ]]; then
    __die "This script has missing dependencies: ${MISSING[*]}"
  fi

  return 0
}

##
# Ensure one or more shared libraries are loaded
#
# Usage: __require_lib <lib name...>
#
# Examples:
#   __require_lib aws # => true
#
function __require_libs() {
  [[ "$@" == "" ]] && return 1

  local LIB_DIR="${_RIV_ROOT}/share/riv/lib"
  local MISSING=()

  for GLOB in "$@"; do
    local LIB_PATH="${LIB_DIR}/${GLOB%.bash}.bash"

    for LIB in $LIB_PATH; do
      if test -f $LIB; then
        source $LIB || __exit 1
      else
        MISSING=( "${MISSING[@]}" "$LIB" )
      fi
    done
  done

  if [[ "${#MISSING[@]}" > 0 ]]; then
    __die "This script requires missing libraries: ${MISSING[@]}"
  fi

  return 0
}
function __require_lib() { __require_libs "$@"; }

##
# Echo, with a timestamp.
#
# Usage: __say [`echo` option] <string>
#
# Examples:
#   __say "here's a message" => 2021-02-23 18:33:16+00:00: here's a message
#   __say -e "foo\tbar"      => 2021-02-23 18:33:16+00:00: foo	bar
#
function __say() {
  local ECHO="echo -e"
  local PREFIX=
  local TIMESTAMP=

  if [[ "$1" =~ ^- ]]; then
    ECHO="echo $1"
    shift
  fi

  if ! __is_systemd_service; then
    TIMESTAMP="$($(which gdate date | head -1) --rfc-3339=seconds): "
  fi

  if [[ "$_RIV_INDENT" -gt 0 ]]; then
    PREFIX=$(printf "%${_RIV_INDENT}s" "")
  fi

  echo -n "${TIMESTAMP}${PREFIX}"

  ${ECHO} "$@"
}

##
# Remove extra indentation from each line of a string
#
# Usage:
#   cat <<EOT | __strip_heredoc | ...
#     foo
#   EOT
#
function __strip_heredoc() {
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
#  echo -e "foo\nbar" | __to_json_array # => ["foo","bar"]
#
function __to_json_array() {
  local INPUT="$(cat -)"

  echo -n "$INPUT" | jq --compact-output --monochrome-output \
    --raw-input --slurp 'split("\n")'
}

##
# Create a temporary directory
#
# Usage:
#  TMPDIR=$(__tmpdir); echo foo > $TMPDIR/foo.txt
#
function __tmpdir() {
  local MKTEMP_BIN=$(which gmktemp mktemp 2>/dev/null | head -1)

  $MKTEMP_BIN -d --tmpdir riv.XXXXXXX
}

##
# Convert input to lower case
#
# Usage: ... | __to_lower
#
# Examples:
#   echo "A Value" | __to_lower # => "a value"
#
function __to_lower() {
  cat - | tr '[:upper:]' '[:lower:]'
}

##
# Reformat a string such that it's safe for use as an ENV variable name
#
# Usage:
#  echo -e "Some\tString!  " | __to_var_name # => "SOME_STRING"
#
function __to_var_name() {
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
#   __trim " foo bar  " # => "foo bar"
#
function __trim() {
  echo "$1" | sed -e 's/^[[:space:]]*//' | sed -e 's/[[:space:]]*$//'
}

##
# URL encode a string
#
# Usage: ... | __urlencode
#
# Examples:
#   echo "foo bar" | __urlencode # => "foo%20bar"
#
function __urlencode() {
  echo -n "$1" | python3 -c "import sys, urllib.parse as u; [sys.stdout.write(u.quote(l, safe='')) for l in sys.stdin]"
}

##
# URL decode a string
#
# Usage: ... | __urldecode
#
# Examples:
#   echo "foo%20bar" | __urldecode # => "foo bar"
#
function __urldecode() {
  echo -n "$1" | python3 -c "import sys, urllib.parse as u; [sys.stdout.write(u.unquote(l)) for l in sys.stdin]"
}

##
# Repeatedly execute some command, stopping when it executes successfully
#
# Usage:
#   Wait for a command to work:
#     __wait_for "date | grep -q 'Tues'"
#   ...checking once/minute:
#     __wait_for "date | grep -q 'Tues'" 60
#   ...with a custom status message:
#     __wait_for "date | grep -q 'Tues'" 60 "Waiting until Tuesday..."
#   ...timing out after a day:
#     __wait_for "date | grep -q 'Tues'" 60 "Waiting until Tuesday..." 86400
#
function __wait_for() {
  [[ "$*" == "" ]] && return 1

  local CMD="$1"
  local SLEEP="${2:-5}"
  local MESSAGE="${3:-.}"
  local TIMEOUT="$4"

  local START="$(date +%s)"

  [[ "$MESSAGE" != "." ]] && __say "$MESSAGE"

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
      __say "$MESSAGE"
    fi
  done

  [[ "$MESSAGE" == "." ]] && echo

  return 0
}


__require_libs stdlib/*
__load_config


if [[ "$RIV_DEBUG" == "1" ]]; then
  export PS4='+ [${BASH_SOURCE##*/}:${LINENO}]'$'\t'
  set -x
fi
