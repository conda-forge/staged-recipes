#!/bin/bash

set -euxo pipefail

cd "${SRC_DIR}"

# conda-forge's mumps-seq splits headers between $PREFIX/include (dmumps_c.h)
# and $PREFIX/include/mumps_seq (dummy mpi.h). Pass both via MUMPS_INCLUDE_DIR
# as a CMake list (semicolon-separated).
# Using -C cmake.define rather than --config-settings=cmake.args so the value
# isn't split on the embedded semicolon. The patch ensures these paths
# actually reach the compile line despite CMake's implicit-include-directory
# stripping (see https://github.com/conda-forge/cmake-feedstock/issues/106).
# BQPD and HIGHS are overridden to empty to neutralize the vendored-dep
# defaults in upstream's pyproject.toml (paths under dependencies/lib/ that
# only exist after running download_dependencies.sh).
$PYTHON -m pip install . -vv \
    --no-deps \
    --no-build-isolation \
    -C cmake.define.BLAS_LIBRARIES="${PREFIX}/lib/libblas.so" \
    -C cmake.define.LAPACK_LIBRARIES="${PREFIX}/lib/liblapack.so" \
    -C cmake.define.METIS_LIBRARY="${PREFIX}/lib/libmetis.so" \
    -C cmake.define.MUMPS_LIBRARY="${PREFIX}/lib/libdmumps_seq.so" \
    -C cmake.define.MUMPS_COMMON_LIBRARY="${PREFIX}/lib/libmumps_common_seq.so" \
    -C cmake.define.MUMPS_PORD_LIBRARY="${PREFIX}/lib/libpord_seq.so" \
    -C cmake.define.MUMPS_MPISEQ_LIBRARY="${PREFIX}/lib/libmpiseq_seq.so" \
    -C cmake.define.MUMPS_INCLUDE_DIR="${PREFIX}/include;${PREFIX}/include/mumps_seq" \
    -C cmake.define.BQPD="" \
    -C cmake.define.HIGHS=""
