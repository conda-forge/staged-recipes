#!/usr/bin/env bash
make release-llvm
# test suite requires rust nightly
# make test
cp target/release/wasmer $PREFIX/bin
