#!/bin/bash
export CC="$GCC"
export CXX="$GXX"

pushd src/github.com/cockroachdb/cockroach
make build
make install

#cd ../cockroach
#ls
#exit 1
#mkdir -p $PREFIX/bin
#mv $GOPATH/bin/cockroach $PREFIX/bin