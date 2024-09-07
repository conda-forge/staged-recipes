#!/bin/bash

set -exou pipefail

link -s ${CXX} ${BUILD_PREFIX}/bin/c++

make install debug=no PREFIX=${PREFIX}

unlink ${BUILD_PREFIX}/bin/c++
