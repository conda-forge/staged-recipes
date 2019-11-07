#!usr/bin/env bash

cd "$SRC_DIR"
cd ..

export GOPATH=$PWD/gopath

mkdir -p "$GOPATH/src/github.com/cockroachdb"
ln -s "$SRC_DIR" "$GOPATH/src/github.com/cockroachdb/cockroach"
cd "$GOPATH/src/github.com/cockroachdb/cockroach"

make build