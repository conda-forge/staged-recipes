#!/usr/bin/env bash
set -e

if [ "${UNAME}" == "Darwin" ]; then
  libext=".dylib"
else
  libext=".so"
fi

export VERBOSE=1
${PYTHON} install.py --prefix="${PREFIX}" \
  --build_type="Release" \
  --coin_root="${PREFIX}" \
  --boost_root="${PREFIX}" \
  --hdf5_root="${PREFIX}" \
  -DCMAKE_OSX_DEPLOYMENT_TARGET="${MACOSX_VERSION_MIN}" \
  -DBLAS_LIBRARIES="${PREFIX}/lib/libopenblas${libext}" \
  -DLAPACK_LIBRARIES="${PREFIX}/lib/liblapack${libext}" \
  --clean
