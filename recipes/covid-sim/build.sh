#!/usr/bin/env bash

CFG=Release
pushd src
  cmake -G"${CMAKE_GENERATOR}" -DCMAKE_BUILD_TYPE=${CFG} -DCMAKE_INSTALL_PREFIX=${PREFIX} .
  cmake --build . --target all --config ${CFG}
popd
cp -Rf data ${PREFIX}
