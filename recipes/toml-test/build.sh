#!/usr/bin/env bash

set -ex

mkdir -p build/
go build -o build ./cmd/toml-test

mkdir -p $PREFIX/bin $PREFIX/share/toml-test
cp -v build/toml-test $PREFIX/bin/toml-test
cp -rv tests $PREFIX/share/toml-test/
