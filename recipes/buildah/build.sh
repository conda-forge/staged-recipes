#! /bin/sh

# Inject prefix path. (With sed since I couldn't get it to work with something
# like EXTRA_LDFLAGS="-X something.condaPrefix=${PREFIX}" in make commands.)
sed -i.bak \
  's|^\(// const char \*condaPrefix =\).*|\1 "'"${PREFIX}"'";|' \
  vendor/github.com/containers/common/pkg/config/config.go
grep -qF \
  "// const char *condaPrefix = \"${PREFIX}\";" \
  vendor/github.com/containers/common/pkg/config/config.go

make \
  GIT_COMMIT= \
  PREFIX="${PREFIX}" \
  bin/buildah docs

make \
  GIT_COMMIT= \
  PREFIX="${PREFIX}" \
  install install.completions


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

gather_licenses ./thirdparty-licenses.txt .
