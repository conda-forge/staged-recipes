#!/usr/bin/env bash

# Turn work folder into GOPATH
export GOPATH=$SRC_DR
export PATH=${GOPATH}/bin:$PATH

pushd cmd/gh

# Build
go build -v -o ${PKG_NAME} .

# Install Binary into PREFIX/bin
mkdir -p $PREFIX/bin
mv ${PKG_NAME} $PREFIX/bin/${PKG_NAME}