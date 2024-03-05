#!/bin/bash

set -ex

# https://github.com/rust-lang/cargo/issues/10583#issuecomment-1129997984
export CARGO_NET_GIT_FETCH_WITH_CLI=true
export IS_IN_RERUN_WORKSPACE=no

cargo-bundle-licenses --format yaml --output THIRDPARTY.yml 

# The CI environment variable means something specific to Rerun. Unset it.
unset CI

mkdir build_cxx
cd build_cxx

cmake ${CMAKE_ARGS} -GNinja .. \
      -DCMAKE_BUILD_TYPE=Release \
      -DBUILD_SHARED_LIBS:BOOL=ON \
      -DRERUN_ARROW_LINK_SHARED:BOOL=ON \
      -DRERUN_DOWNLOAD_AND_BUILD_ARROW:BOOL=OFF \
      -DRERUN_INSTALL_RERUN_C:BOOL=OFF

cmake --build . --config Release
cmake --build . --config Release --target install

if [[ "${CONDA_BUILD_CROSS_COMPILATION:-}" != "1" ]]; then
  ./rerun_cpp/tests/rerun_sdk_tests
fi
