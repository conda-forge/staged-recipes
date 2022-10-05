#!/bin/sh

if [[ "${target_platform}" == osx-* ]]; then
    # See https://conda-forge.org/docs/maintainer/knowledge_base.html#newer-c-features-with-old-sdk
    CXXFLAGS="${CXXFLAGS} -D_LIBCPP_DISABLE_AVAILABILITY"
fi

if [[ "$CONDA_BUILD_CROSS_COMPILATION" == 1 ]]; then
  (
    mkdir -p build-host
    pushd build-host

    export CC=$CC_FOR_BUILD
    export CXX=$CXX_FOR_BUILD
    export LDFLAGS=${LDFLAGS//$PREFIX/$BUILD_PREFIX}
    export PKG_CONFIG_PATH=${PKG_CONFIG_PATH//$PREFIX/$BUILD_PREFIX}

    # Unset them as we're ok with builds that are either slow or non-portable
    unset CFLAGS
    unset CXXFLAGS

    cmake -GNinja .. \
      -DCMAKE_BUILD_TYPE=Release \
      -DCMAKE_PREFIX_PATH=$BUILD_PREFIX -DCMAKE_INSTALL_PREFIX=$BUILD_PREFIX \
      -DCMAKE_INSTALL_LIBDIR=lib \
      -DCMAKE_INSTALL_SYSTEM_RUNTIME_LIBS_SKIP=True \
      -DINSTALL_GZ_MSGS_GEN_EXECUTABLE:BOOL=ON

    cmake --build . --parallel ${CPU_COUNT} --config Release
    cmake --build . --parallel ${CPU_COUNT} --config Release --target install
  )
fi

mkdir build
cd build

if [[ "${CONDA_BUILD_CROSS_COMPILATION}" == "1" ]]; then
  export CMAKE_ARGS="${CMAKE_ARGS} -DProtobuf_PROTOC_EXECUTABLE=$BUILD_PREFIX/bin/protoc -DGZ_MSGS_GEN_EXECUTABLE:BOOL=$BUILD_PREFIX/bin/gz_msgs_gen"
fi

cmake ${CMAKE_ARGS} -GNinja .. \
      -DCMAKE_BUILD_TYPE=Release \
      -DCMAKE_INSTALL_SYSTEM_RUNTIME_LIBS_SKIP=True

cmake --build . --config Release
cmake --build . --config Release --target install
export CTEST_OUTPUT_ON_FAILURE=1
if [[ "${CONDA_BUILD_CROSS_COMPILATION:-}" != "1" || "${CROSSCOMPILING_EMULATOR}" != "" ]]; then
  if [[ "${CONDA_BUILD_CROSS_COMPILATION}" != "" ]]; then
      export CTEST_DISABLED_TESTS="UNIT_ign_TEST"
  fi
  ctest -C Release -E "${CTEST_DISABLED_TESTS}"
fi
