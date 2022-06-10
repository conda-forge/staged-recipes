#!/usr/bin/env bash

set -exu

cmake $CMAKE_ARGS -GNinja -B_build
cmake --build _build
cmake --install _build
