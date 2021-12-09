#!/usr/bin/env bash
set -ex

cmake --version

cmake_options=(
   "-DCMAKE_INSTALL_PREFIX=${PREFIX}"
   "-DCMAKE_INSTALL_LIBDIR=lib"
   "-DBUILD_SHARED_LIBS=ON"
   "-DWITH_FORTRAN08_API=ON"
   "-GNinja"
)

mkdir _build
pushd _build
cmake "${cmake_options[@]}" ..
ninja all install
popd

# Quick & dirty test for checking the installation
mkdir _build_integtest
pushd _build_integtest
CMAKE_PREFIX_PATH=${PREFIX} cmake -G Ninja ../serial_interface/examples/fortran08
ninja all
./test_chimescalc \
  ../serial_interface/tests/force_fields/test_params.CHON.txt \
  ../serial_interface/tests/configurations/CHON.testfile.000.xyz
popd
