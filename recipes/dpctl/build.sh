#!/bin/bash

# This is necessary to help DPC++ find Intel libraries such as SVML, IRNG, etc in build prefix
export LIBRARY_PATH="$LIBRARY_PATH:${BUILD_PREFIX}/lib"

# Intel LLVM must cooperate with compiler and sysroot from conda
echo "--gcc-toolchain=${BUILD_PREFIX} --sysroot=${BUILD_PREFIX}/${HOST}/sysroot -target ${HOST}" > icpx_for_conda.cfg
export ICPXCFG="$(pwd)/icpx_for_conda.cfg"
export ICXCFG="$(pwd)/icpx_for_conda.cfg"

read -r GLIBC_MAJOR GLIBC_MINOR <<<"$(conda list '^sysroot_linux-64$' \
    | tail -n 1 | awk '{print $2}' | grep -oP '\d+' | head -n 2 | tr '\n' ' ')"

if [ -e "_skbuild" ]; then
    ${PYTHON} setup.py clean --all
fi

export CC=icx
export CXX=icpx

export CMAKE_GENERATOR=Ninja
# Make CMake verbose
export VERBOSE=1

# set CMAKE to use less threads to avoid OOM
export CMAKE_BUILD_PARALLEL_LEVEL=2

CMAKE_ARGS="${CMAKE_ARGS} -DDPCTL_LEVEL_ZERO_INCLUDE_DIR=${PREFIX}/include/level_zero -DDPCTL_WITH_REDIST=ON"

# -wnx flags mean: --wheel --no-isolation --skip-dependency-check
${PYTHON} -m build -w -n -x

${PYTHON} -m pip install dist/dpctl*.whl \
    --no-build-isolation \
    --no-deps \
    --only-binary :all: \
    --no-index \
    --prefix "${PREFIX}" \
    -vv
