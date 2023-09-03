##
# Library of config-related bash functions
#

export RIV_CONFIG_JSON=

##
# Search the configuration for an object by type and id/name/alias
#
# Usage: __get_config [selector]
#
# Examples:
#   get entire riv configuration
#     __get_config               # => { ... }
#   get config value by selector
#     __get_config some_selector # => "value at selector"
#   get config value by selector when value is needed
#     __get_config "a value" some_selector # => "a value"
#
function __get_config() {
  if [[ "$#" == "0" ]]; then
    echo "$RIV_CONFIG_JSON"
  elif [[ "$#" == "1" ]]; then
    __get_config | __json_select "$1"
  elif [[ "$#" == "2" ]]; then
    if [[ "$1" != "" ]]; then
      echo "$1"
    else
      __get_config "$2"
    fi
  else
    return 1
  fi
}

##
# Load riv's internal configuration and cache it in memory
#
# Usage: __load_config
#
# Examples:
#   __load_config
#
function __load_config() {
  [[ "$#" == "0" ]] || return 1
  [[ "$RIV_CONFIG_JSON" == "" ]] || return 0

  local CONFIG_PATH=
  local SUPPLEMENTAL_CONFIG_PATH="${_RIV_ROOT}/etc/riv/config.yaml"

  if [[ "$RIV_CONFIG" == "" ]]; then
    CONFIG_PATH="${_RIV_ROOT}/share/riv/config.yaml"
  else
    CONFIG_PATH="$RIV_CONFIG"
  fi

  [[ -r "$CONFIG_PATH" ]] || __die "Could not read riv config: ${CONFIG_PATH}"

  local SUPPLEMENTAL_CONFIG="{}"
  if [[ -e "$SUPPLEMENTAL_CONFIG_PATH" ]]; then
    # shellcheck disable=SC2002
    SUPPLEMENTAL_CONFIG=$(cat "$SUPPLEMENTAL_CONFIG_PATH" | __yaml_to_json)
  fi

  # shellcheck disable=SC2002 disable=SC2016
  RIV_CONFIG_JSON=$(
    cat "$CONFIG_PATH" | __yaml_to_json |
    __jq --sort-keys --compact-output --argjson supplemental_config "$SUPPLEMENTAL_CONFIG" '
      . * $supplemental_config
    '
  )
}

##
# Reload configuration from disk
#
# Usage: __reload_config
#
# Examples:
#   __reload_config
#
function __reload_config() {
  [[ "$#" == "0" ]] || return 1

  RIV_CONFIG_JSON=""

  __load_config
}
