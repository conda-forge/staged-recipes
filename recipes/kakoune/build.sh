#!/bin/bash

set -exo pipefail

ln -s ${CXX} ${BUILD_PREFIX}/bin/c++
make install debug=no PREFIX=${PREFIX}
unlink ${BUILD_PREFIX}/bin/c++
