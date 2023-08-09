# guard against executing this block twice due to bats internals
if [[ "$RIV_BIN" == "" ]]; then
  # helpers for elsewhere in test support code
  export FIXTURE_ROOT="${RIV_ROOT}/cli/test/fixtures"
  export _RIV_ROOT="${RIV_ROOT}/cli/src" # set for us in the `riv` context, but we need it elsewhere
  export RIV_BIN="${_RIV_ROOT}/bin"
  export RIV_COMPLETIONS="${_RIV_ROOT}/completions"
  export RIV_LIBEXEC="${_RIV_ROOT}/libexec"
  export RIV_SHARE="${_RIV_ROOT}/share/riv"

  # load a config fixture for `stdlib/__get_config` and related calls
  export RIV_CONFIG="${FIXTURE_ROOT}/config.yaml"

  # sanitize PATH
  PATH=/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin
  # [[ "$RBENV_ROOT" == "" ]] || PATH="${RBENV_ROOT}/shims:${PATH}"
  export PATH="${RIV_BIN}:${PATH}"
fi

path_without() {
  local exe="$1"
  local path="${PATH}:"
  local tmp_dir=$(mktemp -dt bats.XXXX)
  local found alt util

  for found in $(which -a "$exe"); do
    found="${found%/*}"

    alt="${tmp_dir}/$(echo "${found#/}" | tr '/' '-')"
    mkdir -p "$alt"

    path="$(
      echo "$path" |
      tr ':' "\n" |
      sed "s|^${found}\$|${alt}|" |
      tr "\n" ":"
    )"
  done

  echo "${path%:}"
}
