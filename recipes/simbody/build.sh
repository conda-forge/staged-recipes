#!/bin/bash

# FIXME: This is a hack to make sure the environment is activated.
# The reason this is required is due to the conda-build issue
# mentioned below.
#
# https://github.com/conda/conda-build/issues/910
source activate "${CONDA_DEFAULT_ENV}"

mkdir build
cd build
if [[ "$OSTYPE" == "linux-gnu" ]]; then
	VIZ=on
	SHARED_EXT=so
	# TODO: This test is failing for a yet-to-be-determined reason. See
	# https://github.com/simbody/simbody/issues/400 for more details. Once
	# that is figured out then this test should be enabled.
	SKIP_TEST="-E TestCustomConstraints"
elif [[ "$OSTYPE" == "darwin"* ]]; then
	VIZ=off
	SHARED_EXT=dylib
	SKIP_TEST=""
fi
cmake .. \
	-LAH \
	-DCMAKE_INSTALL_PREFIX="$PREFIX" \
	-DBUILD_USING_OTHER_LAPACK="$PREFIX/lib/libopenblas.$SHARED_EXT" \
	-DBUILD_VISUALIZER=$VIZ
make
ctest $SKIP_TEST
make install
