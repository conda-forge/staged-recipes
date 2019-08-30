#!/usr/bin/env bash
make release-llvm
cp target/release/wasmer $PREFIX/bin
