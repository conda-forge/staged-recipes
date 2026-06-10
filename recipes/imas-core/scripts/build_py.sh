#!/bin/bash
set -ex

# Set version for setuptools_scm
export SETUPTOOLS_SCM_PRETEND_VERSION="${PKG_VERSION}"

# Disable availability macros to avoid issues with older C++ standard libraries
export CXXFLAGS="${CXXFLAGS} -D_LIBCPP_DISABLE_AVAILABILITY"

# Use Ninja as the CMake generator
export CMAKE_GENERATOR=Ninja

# CMake extra configuration:
extra_cmake_args=(
    -G Ninja
    -D CMAKE_C_COMPILER="${CC}"
    -D CMAKE_CXX_COMPILER="${CXX}"
    -D AL_DEVELOPMENT_LAYOUT=OFF
    -D AL_DOWNLOAD_DEPENDENCIES=OFF
    -D AL_PLUGINS=OFF
    # Only build the core library, not the Python bindings
    -D AL_USE_INSTALLED_CORE=ON
    -D AL_PYTHON_BINDINGS=ON
    -D Python_EXECUTABLE="${PYTHON}"
    -D Python3_EXECUTABLE="${PYTHON}"
    # Backends
    -D AL_BACKEND_HDF5=OFF
    -D AL_BACKEND_UDA=OFF
    -D AL_BACKEND_MDSPLUS=OFF
)

cmake ${CMAKE_ARGS} "${extra_cmake_args[@]}" \
    -B build -S "${SRC_DIR}"

# Build and install
cmake --build build --target install