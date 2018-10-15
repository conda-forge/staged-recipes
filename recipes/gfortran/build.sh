#!/bin/bash

CHOST=${macos_machine}
# We do not use -fopenmp here even though it *may* be possible to.
FFLAGS="-march=nocona -mtune=core2 -ftree-vectorize -fPIC -fstack-protector -O2 -pipe"
DEBUG_FFLAGS="-march=nocona -mtune=core2 -ftree-vectorize -fPIC -fstack-protector -O2 -pipe -Og -g -Wall -Wextra -fcheck=all -fbacktrace -fimplicit-none -fvar-tracking-assignments"

pushd ${PREFIX}/bin
  # It is expected this will be built on macOS only:
  ln -s gfortran ${BUILD}-gfortran
popd

find "${RECIPE_DIR}" -name "*activate*.sh" -exec cp {} . \;

find . -name "*activate*.sh" -exec sed -i.bak "s|@CHOST@|${CHOST}|g" "{}" \;
find . -name "*activate*.sh" -exec sed -i.bak "s|@FFLAGS@|${FFLAGS}|g" "{}" \;
find . -name "*activate*.sh" -exec sed -i.bak "s|@DEBUG_FFLAGS@|${DEBUG_FFLAGS}|g" "{}" \;

mkdir -p ${PREFIX}/etc/conda/{de,}activate.d
cp "${SRC_DIR}"/activate-gfortran.sh ${PREFIX}/etc/conda/activate.d/activate-${PKG_NAME}.sh
cp "${SRC_DIR}"/deactivate-gfortran.sh ${PREFIX}/etc/conda/deactivate.d/deactivate-${PKG_NAME}.sh
