#!usr/bin/env bash

export GOPATH=${SRC_DIR}
export PATH=${GOPATH}/bin:$PATH

pushd src/github.com/cockroachdb/${PKG_NAME}

make build

#mkdir -p $PREFIX/bin
#mv ${PKG_NAME} $PREFIX/bin/${PKG_NAME}