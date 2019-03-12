#!/usr/bin/env bash

pushd tests

  # Build sample
  if [[ $(uname) == Darwin ]]; then
    export CONDA_BUILD_SYSROOT=/opt/MacOSX10.9.sdk
  fi
  cmake -DCMAKE_BUILD_TYPE=Debug .
  make -j${CPU_COUNT} VERBOSE=1

  # This MachO object has no DynamicSymbolCommand, testing for bug fixed in PR:
  # https://github.com/lief-project/LIEF/pull/262
  ./test-lief macOS-libpython2.7.a-getbuildinfo.o | grep has_dynamic_symbol_command && exit 1

popd
