#!/bin/bash

set -exuo pipefail

mkdir -p $PREFIX/include
cp -r build/dist/include/* $PREFIX/include
mkdir -p $PREFIX/lib/cmake
cp -r build/dist/lib/cmake/DuckDB $PREFIX/lib/cmake
