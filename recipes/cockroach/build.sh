#!/bin/bash
export CC="$GCC"
export CXX="$GXX"

cd src/github.com/cockroachdb/cockroach
make build
make install