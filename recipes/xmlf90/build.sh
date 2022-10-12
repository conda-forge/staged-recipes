#!/usr/bin/env bash
set -ex

cmake --version

cmake_options=(
   "-DBUILD_SHARED_LIBS=ON"
   "-GNinja"
)

mkdir _build
pushd _build
cmake ${CMAKE_ARGS} "${cmake_options[@]}" ..
ninja all install
popd

if [[ "${CONDA_BUILD_CROSS_COMPILATION:-0}" == "1" ]]; then
  exit 0
fi

# Quick & dirty test for checking the installation
# mkdir _build_integtest
# pushd _build_integtest
# CMAKE_PREFIX_PATH=${PREFIX} cmake -G Ninja ../serial_interface/examples/fortran08
# ninja all
# ./test_chimescalc \
#   ../serial_interface/tests/force_fields/test_params.CHON.txt \
#   ../serial_interface/tests/configurations/CHON.testfile.000.xyz \
#   | grep "Energy (kcal/mol): -7.83714"
# popd
