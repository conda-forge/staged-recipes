#!/usr/bin/env bash
set -ex

mkdir -p $PREFIX/include
cp *.h $PREFIX/include
cp -r internal $PREFIX/include/internal
