#!/usr/bin/env bash

set -o xtrace -o nounset -o pipefail -o errexit

export CXXFLAGS="-D_LIBCPP_DISABLE_AVAILABILITY"
make STRIP=true OPTFLAGS="-O2" CXX="${CXX}" -j${CPU_COUNT}
make PREFIX=${PREFIX} install
