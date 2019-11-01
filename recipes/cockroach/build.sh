#!/usr/bin/env bash

mkdir -p $(go env GOPATH)/src/github.com/cockroachdb
cd $(go env GOPATH)/src/github.com/cockroachdb
#git clone https://github.com/cockroachdb/cockroach
cd cockroach

make build