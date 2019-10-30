#!/bin/bash

export CC=gcc
export CXX=g++

cd $(go env GOPATH)/src/github.com/cockroachdb/cockroach

make
make install

