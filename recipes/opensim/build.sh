#!/bin/bash

# The build instructions for OpenSim 3.3 can be found at:
# http://simtk-confluence.stanford.edu:8080/display/OpenSim/Building+OpenSim+from+Source

# The following are the commands to manually build Opensim inside a conda
# environment.
#mkdir build
#cd build
#cmake .. \
	#-DCMAKE_INSTALL_PREFIX="$CONDA_PREFIX" \
	#-DCMAKE_BUILD_TYPE=Release \
	#-DBUILD_API_EXAMPLES=On \
	#-DBUILD_TESTING=On \
	#-DBUILD_JAVA_WRAPPING=Off \
	#-DBUILD_PYTHON_WRAPPING=Off \
	#-DOPENSIM_STANDARD_11=On \
	#-DSIMBODY_HOME="$CONDA_PREFIX" \
	#-DBUILD_USING_OTHER_LAPACK="$CONDA_PREFIX/lib/libopenblas.so"

# FIXME: This is a hack to make sure the environment is activated. The reason
# this is required is due to the conda-build issue mentioned below:
# https://github.com/conda/conda-build/issues/910
source activate "${CONDA_DEFAULT_ENV}"

mkdir build
cd build
if [[ "$OSTYPE" == "linux-gnu" ]]; then
	SHARED_EXT=so
elif [[ "$OSTYPE" == "darwin"* ]]; then
	SHARED_EXT=dylib
fi
cmake ../OpenSim33-source \
	-DCMAKE_INSTALL_PREFIX="$PREFIX" \
	-DCMAKE_BUILD_TYPE=Release \
	-DBUILD_API_EXAMPLES=On \
	-DBUILD_TESTING=On \
	-DBUILD_JAVA_WRAPPING=Off \
	-DBUILD_PYTHON_WRAPPING=Off \  # NOTE: Only available for Python 2.7
	-DOPENSIM_STANDARD_11=On \
	-DSIMBODY_HOME="$PREFIX" \
	-DBUILD_USING_OTHER_LAPACK="$PREFIX/lib/libopenblas.$SHARED_EXT"
make
# NOTE: Run the tests here in the build directory to make sure things are built
# correctly. This cannot be specified in the meta.yml:test section because it
# won't be run in the build directory.
ctest
make install
