#!/bin/sh
make \
CC=${CC} \
ZLIB_LIBRARY=$PREFIX/lib/libz${SHLIB_EXT} \
ZLIB_INCLUDE_DIR=$PREFIX/include \
EXPAT_LIBRARY=$PREFIX/lib/expat${SHLIB_EXT} \
EXPAT_INCLUDE_DIR=$PREFIX/include \
nifti