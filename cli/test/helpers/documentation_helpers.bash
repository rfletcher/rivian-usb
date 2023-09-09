##
# Assert that a command is properly documented
#
# Usage:
#   assert_documentation <command>
#
function assert_documentation() {
  assert_sufficient_help_output "$1"
  assert_command_summary "$1"
}

##
# Assert that a command is explicitly deprecated
#
# Usage:
#   assert_deprecated <command>
#
function assert_deprecated() {
  local COMMAND="$1"

  run riv help "$COMMAND"

  assert_success

  assert_line "/^Usage: riv ${COMMAND}( |$)/"
  assert_line '/^DEPRECATED/'
}

##
# Assert that a command summary exists, for `riv commands`
#
# Usage:
#   assert_command_summary <command>
#
function assert_command_summary() {
  local COMMAND="$1"

  function _is_exempt() {
    ! riv commands | grep -q "^${1}[ \t]"
  }

  function _get_riv_summary() {
    echo -n "Summary: "
    riv commands | grep "^${1}[ \t]" | sed 's/^[^ ]* *//'
  }

  if _is_exempt "$COMMAND"; then
    skip
  else
    run _get_riv_summary "$COMMAND"

    assert_success '/^Summary: [^ \t]/'
  fi
}

##
# Assert that a command is sufficiently documented for `riv help`
#
# Usage:
#   assert_sufficient_help_output <command>
#
function assert_sufficient_help_output() {
  local COMMAND="$1"

  run riv help "$COMMAND"

  assert_success
  assert_line 1 "/^Usage:.*[( |;]riv ${COMMAND}([) |;]|$)/"
  assert_line '/[^ \t]/' # ensure there's a description
}
