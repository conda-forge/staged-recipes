#! /usr/bin/env bash

set -x

cp ./src/LICENSE ./
module_path="${GOPATH:-"$( go env GOPATH )"}"/src/github.com/containers/podman
mkdir -p "$( dirname "${module_path}" )"
mv ./src "${module_path}"

# We use HAVE_SETNS is a CentOS 6 compat patch.
if \
  printf %s 'char setns (); int main () { setns (); return 0; }' \
  | ${CC} ${CFLAGS} ${CPPFLAGS} ${LDFLAGS} -x c - -o /dev/null ;
then
  export CPPFLAGS="${CPPFLAGS} -DHAVE_SETNS"
fi

make -C "${module_path}" \
  install install.completions \
  ETCDIR="${PREFIX}/etc" \

gather_licenses() {
  # shellcheck disable=SC2039  # Allow widely supported non-POSIX local keyword.
  local module output tmp_dir acc_dir
  output="${1}"
  shift
  tmp_dir="$(pwd)/gather-licenses-tmp"
  acc_dir="$(pwd)/gather-licenses-acc"
  mkdir "${acc_dir}"
  cat > "${output}" <<'EOF'
--------------------------------------------------------------------------------
The output below is generated with `go-licenses csv` and `go-licenses save`.
================================================================================
EOF
  for module ; do
    cat >> "${output}" <<EOF

go-licenses csv ${module}
================================================================================
EOF
    go-licenses csv "${module}" | sort >> "${output}"
    go-licenses save "${module}" --save_path="${tmp_dir}"
    cp -r "${tmp_dir}"/* "${acc_dir}"/
    chmod -R +w "${acc_dir}" "${tmp_dir}"
    rm -r "${tmp_dir}"
  done
  # shellcheck disable=SC2016  # Not expanding $ in single quotes intentional.
  find "${acc_dir}" -type f | sort | xargs -L1 sh -c '
cat <<EOF

--------------------------------------------------------------------------------
${2#${1%/}/}
================================================================================
EOF
cat "${2}"
' -- "${acc_dir}" >> "${output}"
  rm -r "${acc_dir}"
}

gather_licenses ./thirdparty-licenses.txt 'github.com/containers/podman/cmd/podman'
