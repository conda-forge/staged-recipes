#!/bin/sh

mkdir build
cd build

if [[ "${target_platform}" == osx-* ]]; then
    # See https://conda-forge.org/docs/maintainer/knowledge_base.html#newer-c-features-with-old-sdk
    CXXFLAGS="${CXXFLAGS} -D_LIBCPP_DISABLE_AVAILABILITY"
fi

if [ ${target_platform} == "linux-ppc64le" ]; then
  # Disable tests
  GZ_TEST_CMD=-DBUILD_TESTING:BOOL=OFF
  NUM_PARALLEL=-j1
else
  GZ_TEST_CMD=
  NUM_PARALLEL=
fi

cmake ${CMAKE_ARGS} .. \
      -G "Ninja" \
      -DCMAKE_BUILD_TYPE=Release \
      -DCMAKE_INSTALL_SYSTEM_RUNTIME_LIBS_SKIP=True \
      -DFREEIMAGE_RUNS:BOOL=ON \
      -DFREEIMAGE_RUNS__TRYRUN_OUTPUT:STRING="" \
      -DFREEIMAGE_COMPILES:BOOL=ON \
      ${GZ_TEST_CMD}

cmake --build . --config Release ${NUM_PARALLEL}
cmake --build . --config Release --target install ${NUM_PARALLEL}
