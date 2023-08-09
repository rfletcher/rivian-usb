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
#
function __get_config() {
  if [[ "$#" == "0" ]]; then
    echo "$RIV_CONFIG_JSON"
  elif [[ "$#" == "1" ]]; then
    __get_config | __json_select "$1"
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
#   __load_config # => {...}
#
function __load_config() {
  [[ "$#" == "0" ]] || return 1
  [[ "$RIV_CONFIG_JSON" == "" ]] || return

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
    SUPPLEMENTAL_CONFIG=$(cat "$SUPPLEMENTAL_CONFIG_PATH" | __yaml_to_json)
  fi

  RIV_CONFIG_JSON=$(
    cat "$CONFIG_PATH" | __yaml_to_json |
    __jq --sort-keys --compact-output --argjson supplemental_config "$SUPPLEMENTAL_CONFIG" '
      . * $supplemental_config
    '
  )
}