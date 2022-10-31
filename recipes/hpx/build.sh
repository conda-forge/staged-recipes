#!/usr/bin/env bash
set -e


mkdir build
cd build

if [[ "$target_platform" == "osx-64" ]]; then
    # https://conda-forge.org/docs/maintainer/knowledge_base.html#newer-c-features-with-old-sdk
    export CXXFLAGS="${CXXFLAGS} -D_LIBCPP_DISABLE_AVAILABILITY"
fi

cmake $SRC_DIR \
    -G"Ninja" \
    ${CMAKE_ARGS} \
    -D CMAKE_BUILD_TYPE="Release" \
    -D HPX_WITH_EXAMPLES=FALSE \
    -D HPX_WITH_MALLOC="tcmalloc" \
    -D HPX_WITH_NETWORKING=FALSE \
    -D HPX_WITH_TESTS=FALSE
cmake --build . --parallel ${CPU_COUNT}
cmake --install .
