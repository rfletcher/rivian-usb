##
# Assert that some test was successful
#
# Usage:
#   assert [ ! -d "${RIV_ROOT}/target" ]
#
assert() {
  echo "$@"

  if ! "$@"; then
    flunk "failed: $@"
  fi
}

##
# Assert that two values are equal
#
# Usage:
#   assert_equal "foo" "bar"
#
assert_equal() {
  if [[ "$1" != "$2" ]]; then
    { echo "expected: $1"
      echo "actual:   $2"
    } | flunk
  fi
}

##
# Assert than a fatal error occurred
#
# Usage:
#   assert_error
#   assert_error '/some error/'
#
assert_error() {
  if [[ "$1" != "" ]]; then
    assert_line "$1"
  fi

  assert_line '/ Error: /'
  assert_failure
}

##
# Assert that the command returned a non-zero exit status, and optionally that
# it produced specific output.
#
# Usage:
#   assert_failure
#   assert_failure "some output"
#
assert_failure() {
  if [ "$#" -gt 0 ]; then
    assert_output "$1"
  fi

  if [ "$status" -eq 0 ]; then
    flunk "expected non-zero exit status"
  fi
}

##
# Assert that a specific line exists in the program's output, optionally at a
# specific line number
#
# Usage:
#   assert_line "foo"      # any line is "foo"
#   assert_line "/^foo/"   # any line matches /^foo/
#   assert_line 0 "foo"    # line 0 is "foo"
#   assert_line 0 "/^foo/" # line 0 matches /^foo/
#   assert_line 3          # line 3 exists
#
assert_line() {
  if [ "$1" -ge 0 ] 2>/dev/null; then
    if [ "$#" -gt 1 ]; then
      assert_match "$2" "${lines[$1]}"
    else
      local num_lines="${#lines[@]}"
      if [ "$1" -gte "$num_lines" ]; then
        flunk "output has $num_lines lines; expected less than $1"
      fi
    fi
  else
    local line
    for line in "${lines[@]}"; do
      if is_match "$1" "$line"; then return 0; fi
    done
    flunk "expected line '$1'"
  fi
}

##
# Assert that two values match
#
# Usage:
#   assert_match "foo" "foo"  # => true
#   assert_match "/^f/" "foo" # => true
#
assert_match() {
  if ! is_match "$1" "$2"; then
    { echo "expected: ${1:-(empty)}"
      echo "actual:   ${2:-(empty)}"
    } | flunk
  fi
}

##
# Assert that the command produced certain output
#
# Usage:
#   assert_output "foo"
#   assert_output "/^foo/"
#   echo -e "multiple\nlines" | assert_output
#
assert_output() {
  local expected
  if [ $# -eq 0 ]; then
    expected="$(cat -)"
  else
    expected="$1"
  fi
  assert_match "$expected" "$output"
}

##
# Assert that the command returned a zero exit status, and optionally that it
# produced specific output.
#
# Usage:
#   assert_success
#   assert_success "some output"
#
assert_success() {
  if [ "$#" -gt 0 ]; then
    assert_output "$1"
  fi

  if [ "$status" -ne 0 ]; then
    flunk "command failed with exit status $status"
  fi
}

##
# Fail the test, printing an error message
#
# Usage:
#   flunk "1 is not 2"
#   echo -e "multiple\nlines" | flunk
#
flunk() {
  if [ "$#" -eq 0 ]; then
    cat -
  else
    echo "$@"
  fi

  return 1
}

##
# Assert that two values are different
#
# Usage:
#   refute_equal "foo" "bar"
#
refute_equal() {
  if [[ "$1" == "$2" ]]; then
    flunk "expected \"$1\" to differ from \"$2\""
  fi
}

##
# Assert that a specific line does *not* exist in the program's output,
# or that the output has less than N lines
#
# Usage:
#   refute_line "foo"
#   refute_line 5
#
refute_line() {
  if [ "$1" -ge 0 ] 2>/dev/null; then
    local num_lines="${#lines[@]}"
    if [ "$1" -lt "$num_lines" ]; then
      flunk "output has $num_lines lines; expected less than $1"
    fi
  else
    local line
    for line in "${lines[@]}"; do
      if [ "$line" = "$1" ]; then
        flunk "expected to not find line \`$line'"
      fi
    done
  fi
}

##
# Assert that the command did not produce certain output
#
# Usage:
#   refute_output "foo"
#   refute_output "/^foo/"
#   echo -e "multiple\nlines" | refute_output /line/ # => fail
#
refute_output() {
  local expected
  if [ $# -eq 0 ]; then
    expected="$(cat -)"
  else
    expected="$1"
  fi
  ! assert_match "$expected" "$output"
}

##
# Private
#
# Compare a string against another string, or against a regular expression
#
# Usage:
#   is_match "abc" "abc"
#   is_match "/^a/" "abc"
#
is_match() {
  local A="$1"
  local B="$2"

  # Convert our regexp format to Bash regexp format (strip the slash bookends)
  if [[ "${A:0:1}${A:(-1)}" == "//" ]]; then
    A=${A#/}; A=${A%/}

    [[ "$B" =~ $A ]]
  else
    [[ "$B" == "$A" ]]
  fi

  return $?
}
