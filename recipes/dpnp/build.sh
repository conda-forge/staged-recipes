#!/bin/bash

# conda-forge folds the Intel compiler runtime libs (libircmt.lib, ...) into the
# build-only dpcpp_impl package (not visible from the host env), so they live
# in the build prefix and are off the linker's default LIBRARY_PATH
export LIBRARY_PATH="$LIBRARY_PATH:${BUILD_PREFIX}/lib"

# Intel LLVM must cooperate with compiler and sysroot from conda
echo "--gcc-toolchain=${BUILD_PREFIX} --sysroot=${BUILD_PREFIX}/${HOST}/sysroot -target ${HOST}" > icpx_for_conda.cfg
export ICPXCFG="${PWD}/icpx_for_conda.cfg"
export ICXCFG="${ICPXCFG}"

if [ -e "_skbuild" ]; then
    ${PYTHON} setup.py clean --all
fi

export CC=icx
export CXX=icpx

# conda-forge's gcc/g++ activation injects -fno-merge-constants into CFLAGS/CXXFLAGS
# when CONDA_BUILD==1, while icx/icpx doesn't support it and emit the warning.
export CFLAGS="${CFLAGS//-fno-merge-constants/}"
export CXXFLAGS="${CXXFLAGS//-fno-merge-constants/}"

export CMAKE_GENERATOR=Ninja
# Make CMake verbose
export VERBOSE=1

# set CMAKE to use less threads to avoid OOM
export CMAKE_BUILD_PARALLEL_LEVEL=${CPU_COUNT}

CMAKE_ARGS="${CMAKE_ARGS} -DDPNP_WITH_REDIST:BOOL=ON"

# -wnx flags mean: --wheel --no-isolation --skip-dependency-check
${PYTHON} -m build -w -n -x

${PYTHON} -m pip install dist/dpnp*.whl \
    --no-build-isolation \
    --no-deps \
    --only-binary :all: \
    --no-index \
    --prefix "${PREFIX}" \
    -vv
