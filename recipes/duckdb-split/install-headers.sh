#!/bin/bash

set -exuo pipefail

cp -r build/dist/include/* $PREFIX/include
mkdir -p $PREFIX/lib/cmake
cp -r build/dist/lib/cmake/DuckDB $PREFIX/lib/cmake
