#!/usr/bin/env bash

set -ex

mkdir _build
pushd _build
cmake ${CMAKE_ARGS} -GNinja ..
cmake --build .
cmake --install .
popd
