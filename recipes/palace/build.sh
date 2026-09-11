#!/bin/bash
# Build Palace following its official Spack package: all dependencies
# external (PALACE_BUILD_EXTERNAL_DEPS=OFF). Dependencies missing from
# conda-forge are built here as static, position-independent libraries in a
# private prefix (VENDOR) that is linked into palace but never installed, so
# the package ships no files that could clobber other conda-forge packages.

set -ex

VENDOR="${SRC_DIR}/vendor"
mkdir -p "${VENDOR}"

export PKG_CONFIG_PATH="${PREFIX}/lib/pkgconfig:${PKG_CONFIG_PATH:-}"
export CMAKE_PREFIX_PATH="${VENDOR}:${PREFIX}:${CMAKE_PREFIX_PATH:-}"

# With CONDA_BUILD set, the mpich/openmpi compiler wrappers re-source the
# conda compiler activation scripts, which then print their environment diff
# to stdout; CMake's FindMPI parses that output as compile flags and MPI
# detection fails. Unset it so wrapper interrogation output stays clean.
unset CONDA_BUILD

# CMake adds $CONDA_PREFIX to its search path; when the build is launched
# from an activated conda base environment that variable still points there
# and libraries leak in from outside the build prefixes. Pin it to the host
# prefix so find_library/find_package only see declared dependencies.
export CONDA_PREFIX="${PREFIX}"

# CMake also derives search prefixes from PATH entries, so a conda base
# environment on PATH (the one rattler-build runs from) can leak stale
# libraries and CMake package configs into find_package/find_library.
# Restrict PATH to the build/host prefixes and the system directories.
export PATH="${BUILD_PREFIX}/bin:${PREFIX}/bin:/usr/bin:/bin:/usr/sbin:/sbin"

# MPI compiler wrappers (ButterflyPACK/STRUMPACK Fortran needs mpif.h via
# wrappers); point them at the conda-forge cross compilers
export MPICH_CC="${CC}" MPICH_CXX="${CXX}" MPICH_FC="${FC}"
export OMPI_CC="${CC}" OMPI_CXX="${CXX}" OMPI_FC="${FC}"
MPICC="${PREFIX}/bin/mpicc"
MPICXX="${PREFIX}/bin/mpicxx"
MPIFC="${PREFIX}/bin/mpifort"

BLAS_LIBS="${PREFIX}/lib/libblas.so"
LAPACK_LIBS="${PREFIX}/lib/liblapack.so"
SCALAPACK_LIBS="${PREFIX}/lib/libscalapack.so"

COMMON_CMAKE_ARGS=(
  -DCMAKE_BUILD_TYPE=Release
  -DCMAKE_C_COMPILER="${CC}"
  -DCMAKE_CXX_COMPILER="${CXX}"
  -DCMAKE_Fortran_COMPILER="${FC}"
  -DCMAKE_INSTALL_LIBDIR=lib
  -DCMAKE_PREFIX_PATH="${VENDOR};${PREFIX}"
  -DCMAKE_POSITION_INDEPENDENT_CODE=ON
  -DBUILD_SHARED_LIBS=OFF
  # ButterflyPACK (and other older vendored projects) declare
  # cmake_minimum_required < 3.5, which modern CMake refuses outright
  -DCMAKE_POLICY_VERSION_MINIMUM=3.5
)

# -----------------------------------------------------------------------------
# GSLIB (static, MPI)
# -----------------------------------------------------------------------------
make -C "${SRC_DIR}/gslib" -j"${CPU_COUNT}" \
  CC="${CC}" MPI=1 STATIC=1 SHARED=0 BLAS=0 \
  CFLAGS="${CFLAGS} -O2 -fPIC" \
  INSTALL_ROOT="${VENDOR}" install

# -----------------------------------------------------------------------------
# ButterflyPACK (static; STRUMPACK backend for HODLR/HODBF compression)
# -----------------------------------------------------------------------------
cmake -S "${SRC_DIR}/butterflypack" -B "${SRC_DIR}/butterflypack/build" \
  "${COMMON_CMAKE_ARGS[@]}" \
  -DCMAKE_INSTALL_PREFIX="${VENDOR}" \
  -DCMAKE_C_COMPILER="${MPICC}" \
  -DCMAKE_CXX_COMPILER="${MPICXX}" \
  -DCMAKE_Fortran_COMPILER="${MPIFC}" \
  -DCMAKE_Fortran_FLAGS="${FFLAGS} -fallow-argument-mismatch" \
  -DTPL_BLAS_LIBRARIES="${BLAS_LIBS}" \
  -DTPL_LAPACK_LIBRARIES="${LAPACK_LIBS}" \
  -DTPL_SCALAPACK_LIBRARIES="${SCALAPACK_LIBS}" \
  -Denable_doc=OFF \
  -Denable_openmp=ON
# Only the libraries are needed (the EXAMPLE drivers are not linked with
# everything they need and are not installed anyway)
cmake --build "${SRC_DIR}/butterflypack/build" -j"${CPU_COUNT}" \
  --target sbutterflypack dbutterflypack cbutterflypack zbutterflypack
# Install only the library subdirectories (a full install would require the
# EXAMPLE/CPP_INTERFACE targets that were skipped above)
for d in SRC_SINGLE SRC_DOUBLE SRC_COMPLEX SRC_DOUBLECOMPLEX; do
  cmake --install "${SRC_DIR}/butterflypack/build/${d}"
done

# -----------------------------------------------------------------------------
# STRUMPACK (static, with ButterflyPACK + ZFP + ParMETIS)
# -----------------------------------------------------------------------------
cmake -S "${SRC_DIR}/strumpack" -B "${SRC_DIR}/strumpack/build" \
  "${COMMON_CMAKE_ARGS[@]}" \
  -DCMAKE_INSTALL_PREFIX="${VENDOR}" \
  -DCMAKE_Fortran_FLAGS="${FFLAGS} -fallow-argument-mismatch" \
  -DSTRUMPACK_USE_MPI=ON \
  -DSTRUMPACK_USE_OPENMP=ON \
  -DSTRUMPACK_USE_CUDA=OFF \
  -DSTRUMPACK_USE_HIP=OFF \
  -DSTRUMPACK_COUNT_FLOPS=OFF \
  -DSTRUMPACK_BUILD_TESTS=OFF \
  -DSTRUMPACK_BUILD_EXAMPLES=OFF \
  -DTPL_ENABLE_PARMETIS=ON \
  -DTPL_ENABLE_BPACK=ON \
  -DTPL_ENABLE_ZFP=ON \
  -DTPL_ENABLE_SCOTCH=OFF \
  -DTPL_ENABLE_PTSCOTCH=OFF \
  -DTPL_ENABLE_COMBBLAS=OFF \
  -DTPL_ENABLE_PAPI=OFF \
  -DTPL_ENABLE_SLATE=OFF \
  -DTPL_ENABLE_MAGMA=OFF \
  -DTPL_BLAS_LIBRARIES="${BLAS_LIBS}" \
  -DTPL_LAPACK_LIBRARIES="${LAPACK_LIBS}" \
  -DTPL_SCALAPACK_LIBRARIES="${SCALAPACK_LIBS}" \
  -DTPL_METIS_INCLUDE_DIRS="${PREFIX}/include" \
  -DTPL_METIS_LIBRARIES="${PREFIX}/lib/libmetis.so" \
  -DTPL_PARMETIS_INCLUDE_DIRS="${PREFIX}/include" \
  -DTPL_PARMETIS_LIBRARIES="${PREFIX}/lib/libparmetis.so;${PREFIX}/lib/libmetis.so"
cmake --build "${SRC_DIR}/strumpack/build" -j"${CPU_COUNT}"
cmake --install "${SRC_DIR}/strumpack/build"
# STRUMPACK exports the target as STRUMPACK::strumpack, but palace looks for
# strumpack::strumpack and otherwise falls back to the bare archive without
# its link interface (ButterflyPACK, ScaLAPACK, Fortran runtime) — provide a
# lowercase interface target in the installed config
cat >> "${VENDOR}/lib/cmake/STRUMPACK/strumpack-config.cmake" <<'EOF'

if(TARGET STRUMPACK::strumpack AND NOT TARGET strumpack::strumpack)
  add_library(strumpack::strumpack INTERFACE IMPORTED)
  set_target_properties(strumpack::strumpack PROPERTIES
    INTERFACE_LINK_LIBRARIES STRUMPACK::strumpack)
endif()
EOF

# -----------------------------------------------------------------------------
# SUNDIALS (static, MPI + LAPACK; conda-forge sundials is built without MPI)
# -----------------------------------------------------------------------------
cmake -S "${SRC_DIR}/sundials" -B "${SRC_DIR}/sundials/build" \
  "${COMMON_CMAKE_ARGS[@]}" \
  -DCMAKE_INSTALL_PREFIX="${VENDOR}" \
  -DBUILD_STATIC_LIBS=ON \
  -DENABLE_MPI=ON \
  -DENABLE_OPENMP=ON \
  -DENABLE_LAPACK=ON \
  -DLAPACK_LIBRARIES="${LAPACK_LIBS};${BLAS_LIBS}" \
  -DEXAMPLES_ENABLE_C=OFF \
  -DEXAMPLES_ENABLE_CXX=OFF \
  -DEXAMPLES_INSTALL=OFF \
  -DBUILD_TESTING=OFF
cmake --build "${SRC_DIR}/sundials/build" -j"${CPU_COUNT}"
cmake --install "${SRC_DIR}/sundials/build"

# -----------------------------------------------------------------------------
# nlohmann/json-schema-validator (static; not on conda-forge)
# -----------------------------------------------------------------------------
cmake -S "${SRC_DIR}/json-schema-validator" -B "${SRC_DIR}/json-schema-validator/build" \
  "${COMMON_CMAKE_ARGS[@]}" \
  -DCMAKE_INSTALL_PREFIX="${VENDOR}" \
  -DJSON_VALIDATOR_BUILD_TESTS=OFF \
  -DJSON_VALIDATOR_BUILD_EXAMPLES=OFF
cmake --build "${SRC_DIR}/json-schema-validator/build" -j"${CPU_COUNT}"
cmake --install "${SRC_DIR}/json-schema-validator/build"

# -----------------------------------------------------------------------------
# scnlib (static; not on conda-forge). SCN_USE_EXTERNAL_FAST_FLOAT: without
# it scnlib FetchContent-clones fast_float at configure time (no git/network
# on conda-forge CI); fast_float comes from host instead.
# -----------------------------------------------------------------------------
cmake -S "${SRC_DIR}/scnlib" -B "${SRC_DIR}/scnlib/build" \
  "${COMMON_CMAKE_ARGS[@]}" \
  -DCMAKE_INSTALL_PREFIX="${VENDOR}" \
  -DSCN_USE_EXTERNAL_FAST_FLOAT=ON \
  -DSCN_TESTS=OFF \
  -DSCN_EXAMPLES=OFF \
  -DSCN_BENCHMARKS=OFF \
  -DSCN_DOCS=OFF \
  -DSCN_INSTALL=ON
cmake --build "${SRC_DIR}/scnlib/build" -j"${CPU_COUNT}"
cmake --install "${SRC_DIR}/scnlib/build"

# -----------------------------------------------------------------------------
# MFEM 4.9-dev + Palace/Spack patches (static; conda-forge mfem 4.8 is a
# minimal build without the solver integrations Palace requires)
# -----------------------------------------------------------------------------
cmake -S "${SRC_DIR}/mfem" -B "${SRC_DIR}/mfem/build" \
  "${COMMON_CMAKE_ARGS[@]}" \
  -DCMAKE_INSTALL_PREFIX="${VENDOR}" \
  -DMFEM_USE_MPI=YES \
  -DMFEM_USE_METIS_5=YES \
  -DMFEM_USE_LAPACK=YES \
  -DMFEM_USE_OPENMP=YES \
  -DMFEM_THREAD_SAFE=YES \
  -DMFEM_USE_SUPERLU=YES \
  -DMFEM_USE_STRUMPACK=YES \
  -DMFEM_USE_MUMPS=YES \
  -DMFEM_USE_SUNDIALS=YES \
  -DMFEM_USE_GSLIB=YES \
  -DMFEM_USE_ZLIB=YES \
  -DMFEM_USE_CEED=NO \
  -DHYPRE_DIR="${PREFIX}" \
  -DMETIS_DIR="${PREFIX}" \
  -DParMETIS_DIR="${PREFIX}" \
  -DSuperLUDist_DIR="${PREFIX}" \
  -DSuperLUDist_INCLUDE_DIRS="${PREFIX}/include/superlu-dist" \
  -DSuperLUDist_LIBRARIES="${PREFIX}/lib/libsuperlu_dist.so" \
  -DSuperLUDist_REQUIRED_PACKAGES="ParMETIS;METIS;LAPACK;BLAS;MPI;OpenMP" \
  -DSTRUMPACK_DIR="${VENDOR}" \
  -DSTRUMPACK_REQUIRED_PACKAGES="ParMETIS;METIS;LAPACK;BLAS;MPI;MPI_Fortran;OpenMP" \
  -DSTRUMPACK_REQUIRED_LIBRARIES="${VENDOR}/lib/libdbutterflypack.a;${VENDOR}/lib/libzbutterflypack.a;${PREFIX}/lib/libzfp.so;${SCALAPACK_LIBS};gfortran" \
  -DMUMPS_DIR="${PREFIX}" \
  -DMUMPS_REQUIRED_PACKAGES="ParMETIS;METIS;LAPACK;BLAS;MPI;MPI_Fortran;Threads;OpenMP" \
  -DMUMPS_REQUIRED_LIBRARIES="${SCALAPACK_LIBS};gfortran" \
  -DSUNDIALS_DIR="${VENDOR}" \
  -DGSLIB_DIR="${VENDOR}" \
  -DBLAS_LIBRARIES="${BLAS_LIBS}" \
  -DLAPACK_LIBRARIES="${LAPACK_LIBS}"
cmake --build "${SRC_DIR}/mfem/build" -j"${CPU_COUNT}"
cmake --install "${SRC_DIR}/mfem/build"

# -----------------------------------------------------------------------------
# libCEED (static, with LIBXSMM backend from conda-forge; not on conda-forge)
# conda-forge libxsmm puts headers in include/libxsmm/, but libCEED expects
# the upstream layout XSMM_DIR/include/libxsmm.h — provide a shim prefix
# -----------------------------------------------------------------------------
mkdir -p "${SRC_DIR}/xsmm-shim"
ln -sfn "${PREFIX}/include/libxsmm" "${SRC_DIR}/xsmm-shim/include"
ln -sfn "${PREFIX}/lib" "${SRC_DIR}/xsmm-shim/lib"
make -C "${SRC_DIR}/libceed" -j"${CPU_COUNT}" \
  CC="${CC}" CXX="${CXX}" FC= \
  OPT="${CFLAGS} -O3 -fPIC" \
  STATIC=1 OPENMP=1 \
  XSMM_DIR="${SRC_DIR}/xsmm-shim" \
  prefix="${VENDOR}" install

# -----------------------------------------------------------------------------
# Palace itself: superbuild with external deps only
# conda-forge superlu_dist has headers in include/superlu-dist/ and no CMake
# config; palace's find_path only honors SUPERLU_DIST_DIR/include, so give it
# a shim prefix with the layout it expects
# -----------------------------------------------------------------------------
mkdir -p "${SRC_DIR}/superlu-shim"
ln -sfn "${PREFIX}/include/superlu-dist" "${SRC_DIR}/superlu-shim/include"
ln -sfn "${PREFIX}/lib" "${SRC_DIR}/superlu-shim/lib"

# Palace's git_describe walks up parent directories looking for a .git; when
# the build tree happens to live inside an unrelated git repository the lookup
# errors out. A plain-file .git next to the source stops the walk harmlessly.
touch "${SRC_DIR}/palace/.git"
cmake -S "${SRC_DIR}/palace" -B "${SRC_DIR}/palace/build" \
  "${COMMON_CMAKE_ARGS[@]}" \
  -DCMAKE_INSTALL_PREFIX="${PREFIX}" \
  -DPALACE_BUILD_EXTERNAL_DEPS=OFF \
  -DPALACE_WITH_64BIT_INT=OFF \
  -DPALACE_WITH_OPENMP=ON \
  -DPALACE_WITH_CUDA=OFF \
  -DPALACE_WITH_HIP=OFF \
  -DPALACE_WITH_SUPERLU=ON \
  -DPALACE_WITH_STRUMPACK=ON \
  -DPALACE_WITH_STRUMPACK_BUTTERFLYPACK=ON \
  -DPALACE_WITH_STRUMPACK_ZFP=ON \
  -DPALACE_WITH_MUMPS=ON \
  -DPALACE_WITH_SLEPC=ON \
  -DPALACE_WITH_ARPACK=ON \
  -DPALACE_WITH_LIBXSMM=ON \
  -DPALACE_WITH_GSLIB=ON \
  -DPALACE_WITH_SUNDIALS=ON \
  -DMFEM_DIR="${VENDOR}" \
  -DLIBCEED_DIR="${VENDOR}" \
  -DGSLIB_DIR="${VENDOR}" \
  -DSTRUMPACK_DIR="${VENDOR}" \
  -DSUNDIALS_DIR="${VENDOR}" \
  -DHYPRE_DIR="${PREFIX}" \
  -DMETIS_DIR="${PREFIX}" \
  -DPARMETIS_DIR="${PREFIX}" \
  -DSUPERLU_DIST_DIR="${SRC_DIR}/superlu-shim" \
  -DMUMPS_DIR="${PREFIX}" \
  -DSCALAPACK_DIR="${PREFIX}" \
  -DPETSC_DIR="${PREFIX}" \
  -DSLEPC_DIR="${PREFIX}" \
  -DBLAS_LIBRARIES="${BLAS_LIBS}" \
  -DLAPACK_LIBRARIES="${LAPACK_LIBS}"
# The palace superbuild installs during the build step
cmake --build "${SRC_DIR}/palace/build" -j"${CPU_COUNT}"

test -x "${PREFIX}/bin/palace"

# Ship the bundled examples (used by the package test and as user reference)
mkdir -p "${PREFIX}/share/palace"
cp -r "${SRC_DIR}/palace/examples" "${PREFIX}/share/palace/examples"
rm -f "${PREFIX}/share/palace/examples"/*.jl "${PREFIX}/share/palace/examples"/Project.toml
find "${PREFIX}/share/palace/examples" -name "*.jl" -delete
