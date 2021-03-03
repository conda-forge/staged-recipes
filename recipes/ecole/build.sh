#!/usr/bin/env bash

set -o errexit
set -o pipefail
set -o nounset


# For using C++17 symbols on Apple before they are officially released
if [[ "$target_platform" == osx-* ]]; then
	export CXXFLAGS="${CXXFLAGS} -D_LIBCPP_DISABLE_AVAILABILITY"
fi

cmake -B build -S "${SRC_DIR}" -D CMAKE_BUILD_TYPE=Release -D PYTHON_EXECUTABLE="${PYTHON}"
cmake --build build --parallel ${CPU_COUNT}
"${PYTHON}" -m pip install --no-deps build/python/
