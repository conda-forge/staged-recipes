#!/usr/bin/env bash

#export LD_LIBRARY_PATH="${LD_LIBRARY_PATH}:${PREFIX}/lib"
#export LD_LIBRARY_PATH=$PREFIX/lib:$LD_LIBRARY_PATH

# Turn work folder into GOPATH
export GOPATH=$SRC_DR
export PATH=${GOPATH}/bin:$PATH

echo "module runsc" > go.mod

go get gvisor.dev/gvisor/runsc@go

# Change to directory with main.go
pushd runsc

go install -v .

