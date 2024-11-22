#!/bin/sh

rm -rf build
mkdir build
cd build

if [[ "${target_platform}" == osx-* ]]; then
    # See https://conda-forge.org/docs/maintainer/knowledge_base.html#newer-c-features-with-old-sdk
    CXXFLAGS="${CXXFLAGS} -D_LIBCPP_DISABLE_AVAILABILITY"
fi

# The enable options are set to OFF as each plugins is built as its own package
cmake ${CMAKE_ARGS} -GNinja \
      -DCMAKE_BUILD_TYPE=Release \
      -DBUILD_TESTING:BOOL=OFF \
      -DQPSOLVERSEIGEN_USES_SYSTEM_SHAREDLIBPP:BOOL=ON \
      -DQPSOLVERSEIGEN_USES_SYSTEM_YCM:BOOL=ON \
      -DQPSOLVERSEIGEN_ENABLE_OSQP:BOOL=OFF \
      -DQPSOLVERSEIGEN_ENABLE_PROXQP:BOOL=OFF \
      ..

cmake --build . --config Release

cmake --build . --config Release --target install
