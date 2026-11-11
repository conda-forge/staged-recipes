#!/bin/bash

set -euxo pipefail

cd "${SRC_DIR}"

# Override conda-forge's CMAKE_GENERATOR=Unix Makefiles activation default
# so scikit-build-core uses Ninja.
export CMAKE_GENERATOR=Ninja

# conda-forge's mumps-seq splits headers between $PREFIX/include (dmumps_c.h)
# and $PREFIX/include/mumps_seq (dummy mpi.h). Pass both via MUMPS_INCLUDE_DIR
# as a CMake list (semicolon-separated).
# Using -C cmake.define rather than --config-settings=cmake.args so the value
# isn't split on the embedded semicolon.
#
# Upstream's pyproject.toml sets BUILD_SHARED_LIBS=ON, which also installs
# libuno and its headers (COMPONENT libuno) into site-packages. unopy compiles
# the Uno objects directly, so install only the unopy extension, and skip the
# unused static libuno.
#
# Uno has no OpenMP code; USE_OPENMP only links an OpenMP runtime when MUMPS
# is found, so disable it.

$PYTHON -m pip install . -vv \
    --no-deps \
    --no-build-isolation \
    -C install.components=Unspecified \
    -C cmake.define.BUILD_STATIC_LIBS=OFF \
    -C cmake.define.BLAS_LIBRARIES="${PREFIX}/lib/libblas${SHLIB_EXT}" \
    -C cmake.define.LAPACK_LIBRARIES="${PREFIX}/lib/liblapack${SHLIB_EXT}" \
    -C cmake.define.METIS_LIBRARY="${PREFIX}/lib/libmetis${SHLIB_EXT}" \
    -C cmake.define.MUMPS_LIBRARY="${PREFIX}/lib/libdmumps_seq${SHLIB_EXT}" \
    -C cmake.define.MUMPS_COMMON_LIBRARY="${PREFIX}/lib/libmumps_common_seq${SHLIB_EXT}" \
    -C cmake.define.MUMPS_PORD_LIBRARY="${PREFIX}/lib/libpord_seq${SHLIB_EXT}" \
    -C cmake.define.MUMPS_MPISEQ_LIBRARY="${PREFIX}/lib/libmpiseq_seq${SHLIB_EXT}" \
    -C cmake.define.MUMPS_INCLUDE_DIR="${PREFIX}/include;${PREFIX}/include/mumps_seq" \
    -C cmake.define.USE_OPENMP=OFF \
    -C cmake.define.BQPD="" \
    -C cmake.define.SPRAL="" \
    -C cmake.define.HIGHS="${PREFIX}/lib/libhighs${SHLIB_EXT}" \
    -C cmake.define.HIGHS_INCLUDE_DIR="${PREFIX}/include/highs"
