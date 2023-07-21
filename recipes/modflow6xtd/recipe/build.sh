#!/bin/bash
set -ex

# Some conda-forge compilers define MESON_ARGS which needs to be amended or modified
if [[ "${MESON_ARGS}" != *"--prefix"* ]]; then
    MESON_ARGS="${MESON_ARGS} --prefix ${PREFIX}"
fi
if [[ "${MESON_ARGS}" != *"-Dlibdir="* ]] && [[ "${MESON_ARGS}" != *"--libdir"* ]]; then
    # avoid choosing both -Dlibdir=lib and --libdir lib
    MESON_ARGS="${MESON_ARGS} --libdir lib"
fi
if [[ "${MESON_ARGS}" == *"--buildtype release"* ]]; then
    # remove --buildtype, as build will autoconfigure optimization 2
    MESON_ARGS="${MESON_ARGS/--buildtype release/}"
fi
if [[ "${MESON_ARGS}" != *"-Ddebug=false"* ]]; then
    MESON_ARGS="${MESON_ARGS} -Ddebug=false"
fi
if [[ "${MESON_ARGS}" != *"-Dparallel=true"* ]]; then
    MESON_ARGS="${MESON_ARGS} -Dparallel=true"
fi

BUILD_DIR="${SRC_DIR}/builddir"

# configure
meson setup ${MESON_ARGS} ${BUILD_DIR} ${SRC_DIR}

# build
meson compile -C ${BUILD_DIR} -j ${CPU_COUNT}

# test
if [[ "${CONDA_BUILD_CROSS_COMPILATION}" != "1" ]]; then
    pushd examples/ex-gwf-twri01
    ${BUILD_DIR}/src/mf6
    popd
fi

# install
meson install -C ${BUILD_DIR}
