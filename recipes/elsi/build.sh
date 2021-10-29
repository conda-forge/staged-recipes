#!/usr/bin/env bash

set -ex

export CC="$PREFIX/bin/mpicc" FC="$PREFIX/bin/mpifort" CXX="$PREFIX/bin/mpicxx"

INC_PATHS=()
LIB_PATHS=()
LIBS=("-lscalapack" "-llapack" "-lblas")
if [[ "${elpa:-vendor}" = "vendor" ]]; then
  ELPA_OPT="-DUSE_EXTERNAL_ELPA=OFF"
else
  ELPA_OPT="-DUSE_EXTERNAL_ELPA=ON"
  INC_PATHS=($(pkg-config elpa --cflags-only-I | sed s+-I++g) "${INC_PATH[@]}")
  LIB_PATHS=($(pkg-config elpa --libs-only-L) "${LIB_PATHS[@]}")
  LIBS=($(pkg-config elpa --libs-only-l) "${LIBS[@]}")
fi

if [[ "${ntpoly:-vendor}" = "vendor" ]]; then
  NTPOLY_OPT="-DUSE_EXTERNAL_NTPOLY=OFF"
else
  NTPOLY_OPT="-DUSE_EXTERNAL_NTPOLY=ON"
  LIBS=("-lNTPoly" "${LIBS[@]}")
fi

if [[ "${omm:-vendor}" = "vendor" ]]; then
  OMM_OPT="-DUSE_EXTERNAL_OMM=OFF"
else
  OMM_OPT="-DUSE_EXTERNAL_OMM=ON"
  INC_PATHS=($(pkg-config libOMM MatrixSwitch --cflags-only-I | sed s+-I++g) "${INC_PATHS[@]}")
  LIB_PATHS=($(pkg-config libOMM MatrixSwitch --libs-only-L) "${LIB_PATHS[@]}")
  LIBS=($(pkg-config libOMM MatrixSwitch --libs-only-l) "${LIBS[@]}")
fi

cmake_options=(
  ${CMAKE_ARGS}
  "-DCMAKE_Fortran_COMPILER=$FC"
  "-DCMAKE_C_COMPILER=$CC"
  "${ELPA_OPT}"
  "${NTPOLY_OPT}"
  "${OMM_OPT}"
  "-DBUILD_SHARED_LIBS=ON"
  "-DLIBS=${LIBS[*]// /;}"
  "-DLIB_PATHS=${LIB_PATHS[*]// /;}"
  "-DINC_PATHS=${INC_PATHS[*]// /;}"
)

cmake "${cmake_options[@]}" -GNinja -B_build
cmake --build _build
cmake --install _build
