#!/bin/bash
set -ex


GOBIN=$(go env GOBIN)
export GOBIN=$GOBIN

go get -v github.com/google/go-licenses
cp $GOBIN/go-licenses $PREFIX/bin
