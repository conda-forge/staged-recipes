#!/bin/bash
set -eumx -o pipefail
shopt -s failglob
shopt -s extglob

# Test running an example analysis with Make build
pushd Go4ExampleSimple
make clean
make -j"${CPU_COUNT}"
go4analysis -random -number 100000
popd

# Test running another example analysis with CMake build
pushd Go4ExampleUserSource
mkdir build
cmake -S ./ -B ./build/ "${CMAKE_ARGS}"
cmake --build build -j"${CPU_COUNT}"
go4analysis -lib ./build/libGo4UserAnalysis.@(so|dylib) -user tafoil50.scf
go4analysis -lib ./build/libGo4UserAnalysis.@(so|dylib) -user befoil50.scf
popd
