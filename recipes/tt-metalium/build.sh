#!/bin/env/bash
set -e

# Needed so that sfpi can be invoked at build time to generate object files
# sfpi links libmpc.so at runtime
export LD_LIBRARY_PATH=$PREFIX/lib

# Avoid overloading build machine processors and memory
export NUM_PROCS=$((CPU_COUNT / 2))

# Needed by python setup.py
export TT_FROM_PRECOMPILED_DIR=$SRC_DIR

cmake \
  $CMAKE_ARGS \
  -G Ninja \
  -S $SRC_DIR \
  -B $SRC_DIR/build \
  -DCMAKE_BUILD_TYPE=Release \
  -DCMAKE_SKIP_INSTALL_RPATH=ON

cmake --build $SRC_DIR/build --parallel $NUM_PROCS

cmake --install $SRC_DIR/build

# Warning - HACK!
mkdir -p $SRC_DIR/build/lib
ln -sf $PREFIX/lib/_ttnn.so $SRC_DIR/build/lib/_ttnn.so

pip install --no-deps $SRC_DIR

#SFPI compiler binary and runtime loader files are brought in to site-packages
#  via setup.py as of today
#  This was not deemed as acceptable per conda-forge maintainer
#  And its a reasonable objection
#  Why is non python stuff in our python package?
#  For now, keep it in a separate output directory and symlink it for functionality
mkdir -p $PREFIX/share/sfpi_runtime
mv $SP_DIR/runtime $PREFIX/share/sfpi_runtime
ln -sf $PREFIX/share/sfpi_runtime $SP_DIR/runtime

# Again, C++ kernel sources are copied into our site-packages directory
#   Put them in a separate directory and symlink
mkdir -p $PREFIX/share/tt_metal
mv $SP_DIR/tt_metal $PREFIX/share/tt_metal
ln -sf $PREFIX/share/tt_metal $SP_DIR/tt_metal
