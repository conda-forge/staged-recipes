#!/bin/bash

set -e

if [ -z "$PREFIX" ]; then
  PREFIX="$CONDA_PREFIX"
fi

# conda build will copy everything over, including build directories.
# Don't let this pollute the build!
rm -rf build || true

PYTHON_ARGS="$(python ./scripts/get_python_cmake_flags.py)"

mkdir -p build
cd build
cmake -DCMAKE_INSTALL_PREFIX="$PREFIX" -DCMAKE_PREFIX_PATH="$PREFIX" $PYTHON_ARGS ..
make -j20

make install/fast

# Python libraries got installed to wrong place, so move them
# to the right place. See https://github.com/caffe2/caffe2/issues/1015
echo "Installing Python to $SP_DIR"
mv $PREFIX/caffe2 $SP_DIR
