#!/bin/bash
set -ex

# Set version for setuptools_scm
export SETUPTOOLS_SCM_PRETEND_VERSION="${PKG_VERSION}"

# Disable availability macros to avoid issues with older C++ standard libraries
export CXXFLAGS="${CXXFLAGS} -D_LIBCPP_DISABLE_AVAILABILITY"

if [[ "${SUBDIR}" == "osx-arm64" ]] || [[ "${SUBDIR}" == "osx-64" ]]; then
    # MDSplus is not available for macOS, so disable the MDSplus backend on that platform
    export AL_BACKEND_MDSPLUS=OFF
fi

# CMake extra configuration:
extra_cmake_args=(
    -G Ninja
    -D AL_DEVELOPMENT_LAYOUT=OFF
    -D AL_DOWNLOAD_DEPENDENCIES=OFF
    -D AL_PLUGINS=OFF
    # Only build the core library, not the Python bindings
    -D AL_USE_INSTALLED_CORE=OFF
    -D AL_PYTHON_BINDINGS=OFF
    # Backends
    -D AL_BACKEND_HDF5=ON
    -D AL_BACKEND_UDA=ON
    -D AL_BACKEND_MDSPLUS=${AL_BACKEND_MDSPLUS}
)

cmake ${CMAKE_ARGS} "${extra_cmake_args[@]}" \
    -B build -S "${SRC_DIR}"

# Build and install
cmake --build build --target install
