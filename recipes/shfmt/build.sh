#!/usr/bin/env bash

SHFMT_BUILD_DIR=${SRC_DIR}/output

mkdir ${SHFMT_BUILD_DIR}
GOPATH=${SHFMT_BUILD_DIR} GOBIN=${PREFIX}/bin CGO_ENABLED=0 go install -a -ldflags '-extldflags "-static"' ./cmd/shfmt
