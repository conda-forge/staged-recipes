#!/bin/bash

# # Install non-lib artifacts to these special 
# # directories so we can cleanly delete them later.
# TIFF_BIN="${PREFIX}/tiff-bin"
# TIFF_SHARE="${PREFIX}/tiff-share"
# TIFF_DOC="${PREFIX}/tiff-doc"

# mkdir "${TIFF_BIN}" "${TIFF_SHARE}" "${TIFF_DOC}"
mkdir build
cd build

# Pass explicit paths to the prefix for each dependency.
cmake \
    -DCMAKE_INSTALL_PREFIX=${PREFIX} \
    -DCMAKE_INSTALL_LIBDIR=lib \
    ..

make -j"${CPU_COUNT}"

make install

# rm -rf "${TIFF_BIN}" "${TIFF_SHARE}" "${TIFF_DOC}"

# For some reason --docdir is not respected above.
# rm -rf "${PREFIX}/share/doc/tiff*"
