#!/bin/bash
set -eu


if [[ "${target_platform}" == osx-* ]]; then
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
