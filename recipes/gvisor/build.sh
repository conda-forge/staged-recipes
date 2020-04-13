#!/usr/bin/env bash

# Set path to include GOPATH
export PATH=${GOPATH}/bin:$PATH

echo "module runsc" > go.mod

go get github.com/google/gvisor@go

# Change to directory with main.go
pushd runsc

go install -v .