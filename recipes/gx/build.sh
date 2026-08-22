#!/usr/bin/env bash
set -euxo pipefail

# Multi-architecture CUDA build: target the major architectures supported by
# the active toolchain. '-arch=all-major' would also work on CUDA >= 11.5,
# but listing arches explicitly keeps the targets visible and reproducible.
#
# CUDA 13 dropped sm_50 through sm_70 (Maxwell/Pascal/Volta), so compute_70
# is rejected by nvcc 13+. Detect the toolchain major version and emit the
# appropriate gencode list. Volta (sm_70 = V100) is kept on CUDA 12 only.
CUDA_MAJOR=$(nvcc --version | sed -n 's/.*release \([0-9]\+\).*/\1/p')
GENCODE_FLAGS="\
  -gencode=arch=compute_75,code=sm_75 \
  -gencode=arch=compute_80,code=sm_80 \
  -gencode=arch=compute_86,code=sm_86 \
  -gencode=arch=compute_89,code=sm_89 \
  -gencode=arch=compute_90,code=sm_90 \
  -gencode=arch=compute_90,code=compute_90"
if [ "${CUDA_MAJOR}" -lt 13 ]; then
  GENCODE_FLAGS="-gencode=arch=compute_70,code=sm_70 ${GENCODE_FLAGS}"
fi

# The upstream Makefile bakes '${PWD}' (the build directory) into the binary
# as the GX_PATH compile-time define. GX uses GX_PATH at runtime to invoke
# helper scripts under geometry_modules/. Replace that with a Make variable
# set to the install path so conda's prefix-replacement rewrites it at install
# time.
sed -i 's|-DGX_PATH=\\"${PWD}\\"|-DGX_PATH=\\"$(GX_DATA_DIR)\\"|g' Makefile

# The upstream Makefile expects a system-specific Makefiles/Makefile.<GK_SYSTEM>.
# Generate one for the conda-forge build environment.
cat > Makefiles/Makefile.condaforge <<EOF
# conda-forge configuration for GX
# CUDA toolkit, MPI, NetCDF, HDF5, and GSL are all provided by the host env.

NETCDF_INC = -I \${PREFIX}/include
NETCDF_LIB = -L \${PREFIX}/lib -lnetcdf -lnetcdff -lhdf5

MPI_INC = -I \${PREFIX}/include
MPI_LIB = -L \${PREFIX}/lib -lmpi

# CUDA libraries: cudart, NCCL, cuFFT (static), cuBLAS, cuSOLVER, cuTENSOR,
# cuLIBOS (static; shipped in cuda-cudart-static for CUDA 12 and in the
# separate cuda-culibos-static package for CUDA 13+). '-lgomp' pulls in the
# GNU OpenMP runtime that some CUDA static libs reference.
#
# conda-forge's CUDA static libraries (e.g. libcufft_static.a) are installed
# only under \${PREFIX}/targets/x86_64-linux/lib, not the top-level
# \${PREFIX}/lib, so that path must be added explicitly.
#
# Upstream Makefiles also link '-lnvToolsExt', but no GX source references any
# NVTX symbols and CUDA 12 ships only the header-only NVTX3 API on conda-forge
# (no libnvToolsExt.so), so the flag is dropped.
CUDA_INC = -I \${PREFIX}/include
CUDA_LIB = -L \${PREFIX}/lib -L \${PREFIX}/targets/x86_64-linux/lib -lcufft_static -lcublas -lcusolver -lgomp -lcutensor -lnccl -lcudart -lculibos

GSL_INC = -I \${PREFIX}/include
GSL_LIB = -L \${PREFIX}/lib -lgsl -lgslcblas

C_LIB = -lm -lpthread -ldl

# Resolve \${CXX} and \${GENCODE_FLAGS} now (in the shell) so Make sees a path
# literal. Leaving \${CXX} unexpanded would yield a recursive self-reference
# (CXX = \${CXX}) when make evaluates the variable.
# GX_DATA_DIR is the runtime location of geometry_modules/ which the gx binary
# embeds via -DGX_PATH after the sed patch above. Use \${PREFIX} to allow
# conda's prefix-replacement rewrite the baked path at install time.
GX_DATA_DIR = \${PREFIX}/share/gx

CXX = ${CXX}
NVCC = nvcc
# Use conda-forge CFLAGS over '-fPIC -O3'
CFLAGS = ${CFLAGS}
# nvcc forwards unknown flags to the host compiler given
# --forward-unknown-to-host-compiler, so appending \${CFLAGS} pipes the
# conda-forge hardening flags (-march=..., -fstack-protector-strong,
# -fdebug-prefix-map, ...) through to g++ for the host side of the .cu
# compilation. -fPIC and -O2 (the conda-forge default) are provided by
# \${CFLAGS}.
NVCCFLAGS = --forward-unknown-to-host-compiler -ccbin=${CXX} ${GENCODE_FLAGS} -use_fast_math -rdc=true ${CFLAGS}
EOF

export GK_SYSTEM=condaforge

mkdir -p obj/geo

make --jobs="${CPU_COUNT}" gx

mkdir -p "${PREFIX}/bin"

install -m 0755 gx "${PREFIX}/bin/gx"

# Install the geometry helper trees (referenced at runtime via GX_PATH).
# The binary expects ${GX_PATH}/geometry_modules/miller/gx_geo.py and
# similar paths to exist on the user's system after install.
mkdir -p "${PREFIX}/share/gx/geometry_modules"
# Note 'cp -R' is the modern syntax
# c.f. https://pubs.opengroup.org/onlinepubs/9799919799/utilities/cp.html
cp -R geometry_modules/. "${PREFIX}/share/gx/geometry_modules/"

mkdir -p "${PREFIX}/share/gx/post_processing"
cp -R post_processing/. "${PREFIX}/share/gx/post_processing/"
