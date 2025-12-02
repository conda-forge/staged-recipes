#!/bin/bash

# Setuptools SCM configuration
export SETUPTOOLS_SCM_PRETEND_VERSION=${PKG_VERSION}

# Fix by https://conda-forge.org/docs/maintainer/knowledge_base/#newer-c-features-with-old-sdk
CXXFLAGS="${CXXFLAGS} -D_LIBCPP_DISABLE_AVAILABILITY"

# CMake extra configuration:
extra_cmake_args=(
    -G Ninja
    -D BUILD_SHARED_LIBS=ON
    -D CMAKE_INSTALL_RPATH_USE_LINK_PATH=FALSE
    # Backend configuration
    -D AL_BACKEND_HDF5=OFF
    -D AL_BACKEND_MDSPLUS=OFF
    -D AL_BACKEND_UDA=OFF
    # MDSplus models
    -D AL_BUILD_MDSPLUS_MODELS=OFF
    # Python bindings
    -D AL_PYTHON_BINDINGS=no-build-isolation
    -D Python_EXECUTABLE="${PYTHON}"
    -D Python3_EXECUTABLE="${PYTHON}"
    # Download dependencies
    -D AL_DOWNLOAD_DEPENDENCIES=OFF
    # Don't offer al_env.sh
    -D AL_DEVELOPMENT_LAYOUT=OFF
)

cmake ${CMAKE_ARGS} "${extra_cmake_args[@]}" \
    -B build -S "${SRC_DIR}"

# Build
cmake --build build

# Install
${PYTHON} -m pip install ${PKG_NAME} --no-deps --no-build-isolation --find-links build/dist/

# Remove unnecessary files
rm -rf "${SP_DIR}/imas_core.libs"
rm -rf "${SP_DIR}/share/common/"
