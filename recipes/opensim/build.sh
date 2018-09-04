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
#source activate "${CONDA_DEFAULT_ENV}"

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
	-DBUILD_PYTHON_WRAPPING=Off \
	-DOPENSIM_STANDARD_11=On \
	-DSIMBODY_HOME="$PREFIX" \
	-DBUILD_USING_OTHER_LAPACK="$PREFIX/lib/libopenblas.$SHARED_EXT"
make
# NOTE: Run the tests here in the build directory to make sure things are built
# correctly. This cannot be specified in the meta.yml:test section because it
# won't be run in the build directory. The tests are skipped because they take
# an extremely long time to run and cause the CI services to time out.
#ctest -E "testCMC|testOptimizationExampleRuns|testMomentArms|testWrapping"
make install
# NOTE: Some of the executable names installed by OpenSim conflict with
# standard Unix tools. The folllowing renames all then such that they have
# `opensim-` prepended to the executable name.
for filename in analyze forward scale ik id cmc rra versionUpdate
do
	mv $PREFIX/bin/$filename $PREFIX/bin/opensim-$filename
done
# NOTE: This file should be installed so that an enduser can properly link to
# the installed header files which are in a non-standard place on Unix.
cp ../OpenSim33-source/FindOpenSim.cmake $PREFIX/sdk/FindOpenSim.cmake
