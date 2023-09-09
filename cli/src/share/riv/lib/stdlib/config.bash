##
# Library of config-related bash functions
#

##
# Search the configuration for an object by type and id/name/alias
#
# Usage: __get_config [selector]
#
# Examples:
#   get entire riv configuration
#     __get_config # => { ... }
#   get config value by selector
#     __get_config some_selector # => "value at selector"
#   get config value by selector when value is needed
#     __get_config "a value" some_selector # => "a value"
#
function __get_config() {
  if [[ "$#" == "0" ]]; then
    echo "$_RIV_CONFIG"
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
  [[ "$_RIV_CONFIG" == "" ]] || return 0

  local CONFIG_PATHS=(
    "${_RIV_ROOT}/share/riv/config.yaml"
    /etc/riv/config.yaml
    "${HOME}/.config/riv/config.yaml"
  )

  # shellcheck disable=SC2153
  if [[ "$RIV_CONFIG" != "" ]]; then
    [[ -r "$RIV_CONFIG" ]] || __die "Could not read riv config: ${CONFIG_PATH}"

    CONFIG_PATHS=( "$RIV_CONFIG" )
  fi

  _RIV_CONFIG="{}"

  for CONFIG_PATH in "${CONFIG_PATHS[@]}"; do
    if test -r "$CONFIG_PATH"; then
      # shellcheck disable=SC2002 disable=SC2016
      _RIV_CONFIG=$(
        cat "$CONFIG_PATH" | __yaml_to_json |
        jq --sort-keys --compact-output --argjson base_config "$_RIV_CONFIG" '
          $base_config * .
        '
      )
    fi
  done
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

  _RIV_CONFIG=""

  __load_config
}
