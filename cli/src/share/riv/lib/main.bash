##
# A tiny framework for bash scripts.
#
# Usage:
#
# 1. `source` this script in yours
# 2. Define a `main` function
# 3. (Optionally) Define any of these functions, as needed:
#    - `quit`, to handle SIGINT, SIGTERM and shut down cleanly
#    - `reload`, to handle SIGHUP and reload configuration
#    - `handle_arguments`
#    - `handle_options`
#    - `validate_input`
# 4. `main` will be called automatically (after `handle_options`,
#    `handle_arguments` and `validate_input`, if they're defined).

source "${_RIV_ROOT}/share/riv/lib/stdlib.bash" || exit 1

## Set defaults

_RIV_ARGS=( "$@" )
_RIV_MAIN_INITIALIZED=

## Define functions

function __main() {
  if [[ "$_RIV_MAIN_INITIALIZED" != "" ]]; then
    return 0
  else
    _RIV_MAIN_INITIALIZED=1
    trap - EXIT
  fi

  local ARGS=()
  local RIV_OPTIONS=":"

  function ___parse_arguments() {
    local COMMAND_HANDLES_OPTS=
    local OPTIND=0

    # does the command script accept options?
    if __function_exists handle_options; then
      COMMAND_HANDLES_OPTS=1
      handle_options - # set RIV_OPTIONS
    fi

    # parse them either way, so we can warn when options are provided but none are expected
    while getopts "$RIV_OPTIONS" OPT; do
      if [[ "$OPT" == "?" ]]; then
        __die "Unknown option (-${OPTARG}). See \`riv help ${_RIV_COMMAND}\` for usage."
      elif [[ "$COMMAND_HANDLES_OPTS" == "1" ]]; then
        handle_options "$OPT" "$OPTARG"
      fi
    done
    shift $((OPTIND-1))
    unset RIV_OPTIONS

    # save remaining arguments
    ARGS=( "$@" )

    unset _RIV_ARGS
  }

  ___parse_arguments "${_RIV_ARGS[@]}"

  __function_exists handle_arguments && handle_arguments "${ARGS[@]}"
  __function_exists validate_input   && validate_input
  __function_exists main             && main
}

function __quit() {
  __function_exists quit && quit "$1"

  trap - "$1"
  kill -"$1" -$$
  exit
}

# handle ^C, etc.
for SIGNAL in INT TERM; do
  # shellcheck disable=SC2064
  trap "__quit $SIGNAL" "$SIGNAL"
done

# run main()
trap __main EXIT
