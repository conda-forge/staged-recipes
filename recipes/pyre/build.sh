#!/bin/sh
set -euo pipefail

if [ `uname` = "Darwin" ]; then
    # Use specified macOS SDK, and enforce minimum version
    export CXXFLAGS="$CXXFLAGS -isysroot $CONDA_BUILD_SYSROOT"
fi

mkdir build && cd build
cmake $SRC_DIR -DCMAKE_INSTALL_PREFIX=$PREFIX
cmake --build . --target install

# Install python packages to conda's site-package directory
mv $PREFIX/packages/* $SP_DIR/
rmdir $PREFIX/packages
