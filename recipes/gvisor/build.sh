#!/usr/bin/env bash

echo "module runsc" > go.mod

go get github.com/google/gvisor@go

# Change to directory with main.go
pushd runsc

go install -v .