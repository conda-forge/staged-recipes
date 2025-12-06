#!/usr/bin/env bash
set -ex

cd $(find . -maxdepth 1 -type d -name "concurrentqueue-*")

mkdir -p $PREFIX/include
cp *.h $PREFIX/include
cp -r internal $PREFIX/include/internal
