#!/bin/bash
set -ex


GOBIN=$(go env GOBIN)
export GOBIN=$GOBIN

go mod init github.com/google/go-licenses@f29a4c695c3d0bedb950061032f97e90aa28d846
go get -v github.com/google/go-licenses
cp $GOBIN/go-licenses $PREFIX/bin
