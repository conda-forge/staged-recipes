#!/bin/bash

set -exo pipefail

link -s ${CXX} ${BUILD_PREFIX}/bin/c++

make install debug=no PREFIX=${PREFIX} -j{CPU_COUNT}

unlink ${BUILD_PREFIX}/bin/c++
