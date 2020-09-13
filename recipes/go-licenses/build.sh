#!/bin/bash
set -ex


GOBIN=$(go env GOBIN)
export GOBIN=$GOBIN

go get -v github.com/google/go-licenses@f29a4c695c3d0bedb950061032f97e90aa28d846
cp $GOBIN/go-licenses $PREFIX/bin
