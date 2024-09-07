#!/bin/bash

set -exo pipefail

export CPU_COUNT=$(nproc)

ln -s ${CXX} ${BUILD_PREFIX}/bin/c++

make install debug=no PREFIX=${PREFIX} -j{CPU_COUNT}

unlink ${BUILD_PREFIX}/bin/c++
