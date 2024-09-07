#!/bin/bash

set -exo pipefail

export LIBRARY_PATH="${PREFIX}/lib"

ln -s ${CXX} ${BUILD_PREFIX}/bin/c++
make install debug=no PREFIX=${PREFIX} -l${LIBRARY_PATH}" -j${CPU_COUNT}
unlink ${BUILD_PREFIX}/bin/c++
