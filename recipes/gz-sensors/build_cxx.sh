#!/bin/sh

if [[ "${target_platform}" == osx-* ]]; then
    # See https://conda-forge.org/docs/maintainer/knowledge_base.html#newer-c-features-with-old-sdk
    CXXFLAGS="${CXXFLAGS} -D_LIBCPP_DISABLE_AVAILABILITY"
fi

rm -rf build
mkdir build
cd build

cmake ${CMAKE_ARGS} -GNinja \
      -DCMAKE_BUILD_TYPE=Release \
      -DCMAKE_INSTALL_SYSTEM_RUNTIME_LIBS_SKIP=TRUE \
      -DCMAKE_MACOSX_RPATH=FALSE \
      -DBUILD_SHARED_LIBS=ON \
      -DBUILD_TESTING=ON \
      ..

cmake --build . --config Release
cmake --build . --config Release --target install


if [[ "${CONDA_BUILD_CROSS_COMPILATION:-}" != "1" || "${CROSSCOMPILING_EMULATOR}" != "" ]]; then
  if [[ ${HOST} =~ .*darwin.* ]]; then
    ctest -VV --output-on-failure -C Release -E "UNIT_Lidar_TEST|UNIT_Camera_TEST|INTEGRATION"
  else
    ctest -VV --output-on-failure -C Release
  fi
fi
