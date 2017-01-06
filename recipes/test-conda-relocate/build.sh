#!/usr/bin/env bash

set -e

cmake -DCMAKE_INSTALL_PREFIX=$PREFIX -DCMAKE_GENERATOR="$CMAKE_GENERATOR" .
make install
