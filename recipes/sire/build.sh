#!/usr/bin/env bash

# Build script for Sire conda-forge package.

set -ex

# Ensure CMake doesn't strip ${PREFIX}/include from the include directories
# when building the wrappers.
sed -i.bak -e '262s/# u/u/' wrapper/CMakeLists.txt

# The default Sire build uses OpenMM from the Omnia channel which uses the
# old C++ binary ABI. The OpenMM package from conda-forge uses the new ABI.
sed -i.bak -e '555s/ABI=0/ABI=1/' corelib/CMakeLists.txt

# Set the MACOSX_DEPLOYMENT_TARGET to make sure that we can work with
# Mavericks or above (needed by Qt5).
export MACOSX_DEPLOYMENT_TARGET="10.9"

# Make the build directories.
mkdir -p build/corelib
mkdir -p build/wrapper

# Build and install the core library.
cd build/corelib
cmake -D ANACONDA_BUILD=ON -D ANACONDA_BASE=${PREFIX} -D BUILD_NCORES=$CPU_COUNT ../../corelib
cmake --build . --target install -- VERBOSE=1 -j$CPU_COUNT

# Build and install the Python wrappers.
cd ../wrapper
cmake -D ANACONDA_BUILD=ON -D ANACONDA_BASE=${PREFIX} -D BUILD_NCORES=$CPU_COUNT ../../wrapper
cmake --build . --target install -- VERBOSE=1 -j$CPU_COUNT
