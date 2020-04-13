#!/usr/bin/env bash

# Turn work folder into GOPATH
export GOPATH=${SRC_DIR}
export PATH=${GOPATH}/bin:$PATH

echo "module runsc" > go.mod

go get github.com/google/gvisor@go

# Change to directory with main.go
pushd runsc

go install -v .