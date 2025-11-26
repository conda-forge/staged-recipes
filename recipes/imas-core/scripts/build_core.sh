#!/bin/bash

# Fix by https://conda-forge.org/docs/maintainer/knowledge_base/#newer-c-features-with-old-sdk
CXXFLAGS="${CXXFLAGS} -D_LIBCPP_DISABLE_AVAILABILITY"

# CMake extra configuration:
extra_cmake_args=(
    -G Ninja
    -D BUILD_SHARED_LIBS=ON
    -D CMAKE_INSTALL_RPATH_USE_LINK_PATH=FALSE
    # Backend configuration
    -D AL_BACKEND_HDF5=ON
    -D AL_BACKEND_MDSPLUS=OFF
    -D AL_BACKEND_UDA=ON
    # MDSplus models
    -D AL_BUILD_MDSPLUS_MODELS=OFF
    # Python bindings
    -D AL_PYTHON_BINDINGS=OFF
    # Download dependencies
    -D AL_DOWNLOAD_DEPENDENCIES=OFF
    # Don't offer al_env.sh
    -D AL_DEVELOPMENT_LAYOUT=OFF
)

cmake ${CMAKE_ARGS} "${extra_cmake_args[@]}" \
    -B build -S "${SRC_DIR}"

# Install
cmake --build build --target install

# Remove unnecessary files
rm -rf "${PREFIX}/share/common/"
