#!/usr/bin/env bash
set -eux

export GOPATH="$( pwd )"
export CGO_ENABLED=1

module='github.com/ipfs/go-ipfs'

make -C "src/${module}" \
  install \
  GOTAGS=openssl

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
    go get -d "${module}"
    chmod -R +rw "$( go env GOPATH )"
    go-licenses csv "${module}" | sort >> "${output}"
    go-licenses save "${module}" --force --save_path="${tmp_dir}"
    cp -r "${tmp_dir}"/* "${acc_dir}"/
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
  rm -r "${acc_dir}" "${tmp_dir}"
}

# TODO: figure out what to do with
#
# gather_licenses ./third-party-licenses.txt "${module}/cmd/ipfs"
#
# fails with
# F0206 15:06:39.374624  156753 main.go:43] one or more libraries have an incompatible/unknown license:
# map["unknown":[
#     "github.com/ipfs/go-ipfs/vendor/github.com/ipfs/bbloom"
#     "github.com/ipfs/go-ipfs/vendor/github.com/ipfs/go-cidutil"
#     "github.com/ipfs/go-ipfs/vendor/github.com/ipfs/go-cidutil/cidenc"
#     "github.com/ipfs/go-ipfs/vendor/github.com/ipfs/go-ipld-git"
#     "github.com/ipfs/go-ipfs/vendor/github.com/ipfs/go-verifcid"
#     "github.com/ipfs/go-ipfs/vendor/github.com/ipld/go-car"
#     "github.com/ipfs/go-ipfs/vendor/github.com/ipld/go-car/util"
#     "github.com/ipfs/go-ipfs/vendor/github.com/libp2p/go-libp2p-asn-util"
#     "github.com/ipfs/go-ipfs/vendor/github.com/libp2p/go-libp2p-noise"
#     "github.com/ipfs/go-ipfs/vendor/github.com/libp2p/go-libp2p-noise/pb"
#     "github.com/ipfs/go-ipfs/vendor/github.com/multiformats/go-base36"
#     "github.com/ipfs/go-ipfs/vendor/github.com/whyrusleeping/base32"
#     "github.com/ipfs/go-ipfs/vendor/github.com/whyrusleeping/cbor-gen"
#]]
