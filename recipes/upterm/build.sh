#!/bin/bash
set -euxo pipefail

export LDFLAGS="${LDFLAGS:-} -s -w -X github.com/owenthereal/upterm/internal/version.Version=${PKG_VERSION}"

go build -ldflags "${LDFLAGS}" -o "${PREFIX}/bin/upterm" ./cmd/upterm
go build -ldflags "${LDFLAGS}" -o "${PREFIX}/bin/uptermd" ./cmd/uptermd

# tj/go-update and tj/go cause linting errors
# in the license generation code
# https://github.com/conda-forge/staged-recipes/pull/31666/files/5334b8274ecc6aa56a74709271dd94bd0eb77513#r2607310667
# the "|| true"
# allows the command to succeed and to generate the license files it can
go-licenses save ./cmd/upterm ./cmd/uptermd --save_path="${SRC_DIR}/license-files" || true
