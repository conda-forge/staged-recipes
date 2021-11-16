#!/usr/bin/env bash

set -ex

export CC="$PREFIX/bin/mpicc" FC="$PREFIX/bin/mpifort" CXX="$PREFIX/bin/mpicxx"

INC_PATHS=(
  $(pkg-config elpa_openmp --cflags-only-I | sed s+-I++g)
  $(pkg-config libOMM MatrixSwitch --cflags-only-I | sed s+-I++g)
)
LIB_PATHS=(
  $(pkg-config elpa_openmp --libs-only-L)
  $(pkg-config libOMM MatrixSwitch --libs-only-L)
)
LIBS=(
  $(pkg-config elpa_openmp --libs-only-l)
  "-lNTPoly"
  $(pkg-config libOMM MatrixSwitch --libs-only-l)
  "-lscalapack"
  "-llapack"
  "-lblas"
)

cmake_options=(
  ${CMAKE_ARGS}
  "-DCMAKE_Fortran_COMPILER=$FC"
  "-DCMAKE_C_COMPILER=$CC"
  "-DUSE_EXTERNAL_ELPA=ON"
  "-DUSE_EXTERNAL_NTPOLY=ON"
  "-DUSE_EXTERNAL_OMM=ON"
  "-DBUILD_SHARED_LIBS=ON"
  "-DLIBS=${LIBS[*]// /;}"
  "-DLIB_PATHS=${LIB_PATHS[*]// /;}"
  "-DINC_PATHS=${INC_PATHS[*]// /;}"
)

cmake "${cmake_options[@]}" -GNinja -B_build
cmake --build _build
cmake --install _build
