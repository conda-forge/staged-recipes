#!/bin/bash

set -exo pipefail

cat <<EOF > fallback_fmaxmag.h
/*
  These fallback definitions are needed because fmaxmag() and fmaxmagf()
  are non-standard HPC/GPU extension functions (not provided by glibc or
  the C/C++ standard library). Host compilation will fail if these symbols
  are missing. This header injects simple versions of these functions so
  that the build can succeed on standard Linux toolchains.
*/
#ifndef FALLBACK_FMAXMAG_H
#define FALLBACK_FMAXMAG_H

#include <cmath>

inline float fmaxmagf(float x, float y) {
  float ax = std::fabs(x);
  float ay = std::fabs(y);
  if (ax > ay) return x;
  if (ay > ax) return y;
  // In case of a tie, we pick x arbitrarily.
  return x;
}

inline double fmaxmag(double x, double y) {
  double ax = std::fabs(x);
  double ay = std::fabs(y);
  if (ax > ay) return x;
  if (ay > ax) return y;
  // In case of a tie, we pick x arbitrarily.
  return x;
}

#endif // FALLBACK_FMAXMAG_H
EOF

export CXXFLAGS="$CXXFLAGS -include $PWD/fallback_fmaxmag.h"

cmake \
  $SRC_DIR \
  ${CMAKE_ARGS} \
  -G Ninja \
  -B build \
  -DBUILD_SHARED_LIBS=ON \
  -DCMAKE_BUILD_TYPE=Release

cmake --build build --parallel

cmake --install build
