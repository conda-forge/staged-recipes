#!/bin/bash

mkdir -vp ${PREFIX}/lib;

export CXXLAGS="${CFLAGS}"
export CPPFLAGS="-I${PREFIX}/include"
export LDFLAGS="-L${PREFIX}/lib"

make -e HDF5_INSTALL="${PREFIX}"
cp lib* ${PREFIX}/lib

mkdir -p $PREFIX/etc/conda/activate.d
mkdir -p $PREFIX/etc/conda/deactivate.d

ACTIVATE=$PREFIX/etc/conda/activate.d/plugin_path.sh
DEACTIVATE=$PREFIX/etc/conda/deactivate.d/plugin_path.sh

# set up
echo "export HDF5_PLUGIN_PATH=\$CONDA_ENV_PATH/lib"> $ACTIVATE

# tear down
echo "unset HDF5_PLUGIN_PATH" > $DEACTIVATE

# clean up after self
unset ACTIVATE
unset DEACTIVATE
