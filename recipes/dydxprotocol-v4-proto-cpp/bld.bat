@echo off
setlocal EnableDelayedExpansion

pushd v4-client-cpp
  mkdir _conda-build
  pushd _conda-build
    cmake .. ^
      -DCMAKE_BUILD_TYPE=Release ^
      -DCMAKE_PREFIX_PATH="%PREFIX%/lib" ^
      -DCMAKE_INSTALL_PREFIX="%PREFIX%" ^
      -DBUILD_SHARED_LIBS=ON ^
      -DCMAKE_FIND_PACKAGE_PREFER_CONFIG=ON ^
      -G Ninja

    cmake --build . --target dydx_v4_proto -- -j%CPU_COUNT%
    cmake --install .
  popd
popd
