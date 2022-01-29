#!/bin/bash
set -eu

# https://docs.conda.io/projects/conda-build/en/latest/user-guide/environment-variables.html#environment-variables-set-during-the-build-process

if [ -n "${MACOSX_DEPLOYMENT_TARGET:-}" ]; then
  MACHINE=darwin
else
  MACHINE=linux
fi
make "build-${MACHINE}-amd${ARCH}"

mkdir -p $PREFIX/bin
cp \
  "${SRC_DIR}/bin/${MACHINE}_amd${ARCH}/ssmcli" \
  "${SRC_DIR}/bin/${MACHINE}_amd${ARCH}_plugin/session-manager-plugin" \
  "$PREFIX/bin"

# Some vendor directories don't have a licence file
GOPATH="$( pwd )/vendor" go-licenses save ./src/sessionmanagerplugin-main/ ./src/ssmcli-main/ --save_path=./license-files || true

test -d license-files/github.com
