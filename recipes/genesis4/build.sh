#!/usr/bin/env bash

# for cross compiling using openmpi
export OPAL_PREFIX="$PREFIX"

MPI_BUILD_DIR="build_${mpi}"

# The packaged CMake configuration erroneously specifies build flags,
# interfering with conda-build's own flags.  Patch the config so that the
# correct CXXFLAGS will make their way through:
sed -i -e "s/^\(set(CMAKE_CXX_FLAGS\)/#\1/" CMakeLists.txt
# Note: Without the above, headers for fftw and hdf5 will be found in the
# ``cmake`` step but fail to be found in the ``make`` step.

cmake \
    -S . \
    -B "$MPI_BUILD_DIR" \
    ${CMAKE_ARGS} \
    -DCMAKE_BUILD_TYPE=Release \
    -DCMAKE_INSTALL_PREFIX="${PREFIX}" \
    -DMPICXX="$(which mpicxx)" \
    \
    || \
 {
    cat "${MPI_BUILD_DIR}/CMakeFiles/CMakeConfigureLog.yaml";
    exit 1; 
 }

cd "${MPI_BUILD_DIR}" || exit

make -j "${CPU_COUNT}"
cp genesis4 "${PREFIX}/bin"
