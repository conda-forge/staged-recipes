#!/bin/bash

if [[ "$target_platform" == linux* ]]; then
  set
  pwd
  ls -R .
  cp ${RECIPE_DIR}/CMakeLists.txt launcher/CMakeLists.txt
  pushd launcher
  cmake CMakeLists.txt
  cmake --build . --config Release
  ls -R .
  mkdir -p linux
  mv build linux/x64
  popd
  "${PYTHON}" -m pip install --no-deps --ignore-installed .
fi

if [[ "$target_platform" == "osx-64" ]]; then
  set
  pwd
  ls -R .
  cp ${RECIPE_DIR}/CMakeLists.txt launcher/CMakeLists.txt
  pushd launcher
  cmake CMakeLists.txt
  cmake --build . --config Release
  ls -R .
  mkdir -p build/Release
  mv build/*.app build/Release
  popd
  ls -R .
  "${PYTHON}" -m pip install --no-deps --ignore-installed .
fi
