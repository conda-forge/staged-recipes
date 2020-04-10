#!/usr/bin/env bash

# Turn work folder into GOPATH
export GOPATH=$SRC_DR
export PATH=${GOPATH}/bin:$PATH

echo "module runsc" > go.mod

# Change to directory with main.go
pushd runsc

go install -v .