#!/bin/bash

export CPATH="${PREFIX}/include:$CPATH"
export LIBRARY_PATH="${PREFIX}/lib:$LIBRARY_PATH"
MYNCPU=$(( (CPU_COUNT > 8) ? 8 : CPU_COUNT ))

if [ `uname` == Darwin ]; then
    export DYLD_FALLBACK_LIBRARY_PATH="${PREFIX}/lib"
else
    export LD_LIBRARY_PATH="${PREFIX}/lib"
fi

# use macos SDK
if [ $build_platform = "osx-64" ]
then
  echo "Use SDK at ${CONDA_BUILD_SYSROOT}."
  export CXXFLAGS="${CXXFLAGS} -isysroot ${CONDA_BUILD_SYSROOT}"
fi

scons -j $MYNCPU install prefix=$PREFIX

python -m pip install . --no-deps
# Add more build steps here, if they are necessary.

# See http://docs.continuum.io/conda/build.html
# for a list of environment variables that are set during the build process.
