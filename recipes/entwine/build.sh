#!/bin/bash

set -ex


cmake -G "Unix Makefiles" \
      -DCMAKE_INSTALL_PREFIX:PATH="${PREFIX}" \
      -DCMAKE_BUILD_TYPE:STRING=Release \
      -DCMAKE_LIBRARY_PATH="${PREFIX}/lib" \
      -DPDAL_DIR="${PREFIX}/lib/pdal/cmake/" \
      -DCMAKE_INCLUDE_PATH="${PREFIX}/include"

# CircleCI offers two cores.
make -j $CPU_COUNT
make install
