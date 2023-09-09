HELPERS="${HELPERS} jq"

function _jq_setup() {
  # stdlib.bash defines __jq()
  . ${RIV_SHARE}/lib/stdlib.bash
}

function run_jq() {
  run_jq_stdin "" "$@"
}

function run_jq_stdin() {
  local STDIN="$1"; shift;

  if [[ "$STDIN" == "" ]]; then
    EXTRA_OPTS='--null-input'
  fi

  run_stdin "$STDIN" __jq $EXTRA_OPTS "$@"
}
