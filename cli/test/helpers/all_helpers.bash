export HELPERS="
  env
  assertion
  documentation
  json
"

export RIV_ROOT="${BATS_CWD}"

setup() {
  _run_setup_or_teardown setup
}

teardown() {
  _run_setup_or_teardown teardown
}

run_stdin() {
  local input="$1"; shift
  local e E T oldIFS
  [[ ! "$-" =~ e ]] || e=1
  [[ ! "$-" =~ E ]] || E=1
  [[ ! "$-" =~ T ]] || T=1
  set +e
  set +E
  set +T
  output="$(echo "$input" | "$@" 2>&1)"
  status="$?"
  oldIFS=$IFS
  IFS=$'\n' lines=($output)
  [ -z "$e" ] || set -e
  [ -z "$E" ] || set -E
  [ -z "$T" ] || set -T
  IFS=$oldIFS
}

_run_setup_or_teardown() {
  local TYPE="$1"

  _run_if_exists() {
    local FN="$1"

    if [[ $(type -t "$FN") == "function" ]]; then
      "$FN"
    fi

    return $?
  }

  # run test teardown
  if [[ "${TYPE}" == "teardown" ]]; then
    _run_if_exists "_${TYPE}"
  fi

  # run helper setup/teardown
  for HELPER in $HELPERS; do
    _run_if_exists "_${HELPER}_${TYPE}"
  done

  # run test setup
  if [[ "${TYPE}" == "setup" ]]; then
    _run_if_exists "_${TYPE}"
  fi
}

bats_require_minimum_version 1.5.0

# load common helpers
for HELPER in $HELPERS; do
  load "${RIV_ROOT}/cli/test/helpers/${HELPER}_helpers.bash"
done
