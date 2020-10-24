#!/bin/bash

set -ex

export CXXFLAGS="${CXXFLAGS} -std=c++11"
if [ "$(uname)" == "Linux" ]; then
   export LDFLAGS="${LDFLAGS} -Wl,-rpath-link,${PREFIX}/lib"
fi

mdkir build
cd build

cmake -DCMAKE_BUILD_TYPE=Rel -DENABLE_TESTS=ON ..

# CircleCI offers two cores.
make -j $CPU_COUNT

