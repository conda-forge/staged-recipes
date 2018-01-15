#!/usr/bin/env bash

cd "${SRC_DIR}/.."
mkdir "src"
mkdir "src/github.com"
mkdir "src/github.com/opencontainers"
mkdir "src/github.com/tianon"
mv "${SRC_DIR}" "src/github.com/tianon/gosu"

export RUNC_VERSION="0.1.0"
curl -L https://github.com/opencontainers/runc/archive/v${RUNC_VERSION}.tar.gz | tar -xzC "src/github.com/opencontainers"
mv "src/github.com/opencontainers/runc-${RUNC_VERSION}" "src/github.com/opencontainers/runc"

export CGO_ENABLED=0
export GOARCH="amd64"
export GOOS="linux"
export GOPATH="$(pwd)"

cd "src/github.com/tianon/gosu"
go build -v -ldflags '-d -s -w' -o "${PREFIX}/bin/gosu"

mkdir -p "${SRC_DIR}"
cp "LICENSE" "${SRC_DIR}/LICENSE"
