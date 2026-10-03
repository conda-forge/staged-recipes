#!/usr/bin/env bash

set -euo pipefail

symmetrix_source="${SRC_DIR}"
lammps_source="${SRC_DIR}/lammps"
build_directory="${SRC_DIR}/lammps-build-cpu"

test -f "${symmetrix_source}/libsymmetrix/external/kokkos-kernels/CMakeLists.txt"
test -f "${lammps_source}/src/version.h"

"${symmetrix_source}/pair_symmetrix/install.sh" "${lammps_source}"

export CMAKE_BUILD_PARALLEL_LEVEL="${CPU_COUNT:-2}"
export CXXFLAGS="${CXXFLAGS:-} -ffile-prefix-map=${SRC_DIR}=/usr/local/src/conda/symmetrix-xl-lammps"

cmake_args=()
if [[ -n ${CMAKE_ARGS:-} ]]; then
  read -r -a cmake_args <<<"${CMAKE_ARGS}"
fi

cmake -S "${lammps_source}/cmake" -B "${build_directory}" \
  -G "Unix Makefiles" \
  "${cmake_args[@]}" \
  -DCMAKE_BUILD_TYPE=Release \
  -DCMAKE_INSTALL_PREFIX="${PREFIX}" \
  -DCMAKE_INSTALL_RPATH="\${ORIGIN}/../lib" \
  -DCMAKE_CXX_STANDARD=20 \
  -DCMAKE_CXX_COMPILER="${CXX}" \
  -DCMAKE_CUDA_COMPILER=NOTFOUND \
  -DBUILD_MPI=ON \
  -DMPI_CXX_COMPILER="${PREFIX}/bin/mpicxx" \
  -DBUILD_SHARED_LIBS=OFF \
  -DDOWNLOAD_POTENTIALS=OFF \
  -DDOWNLOAD_KOKKOS=OFF \
  -DEXTERNAL_KOKKOS=OFF \
  -DFFT=FFTW3 \
  -DFFT_KOKKOS=FFTW3 \
  -DFFT_USE_HEFFTE=OFF \
  -DPKG_ASPHERE=ON \
  -DPKG_BODY=ON \
  -DPKG_BROWNIAN=ON \
  -DPKG_CLASS2=ON \
  -DPKG_COLLOID=ON \
  -DPKG_COLVARS=OFF \
  -DPKG_COMPRESS=OFF \
  -DPKG_CORESHELL=ON \
  -DPKG_DIPOLE=ON \
  -DPKG_ELECTRODE=ON \
  -DPKG_EXTRA-COMPUTE=ON \
  -DPKG_EXTRA-DUMP=ON \
  -DPKG_EXTRA-FIX=ON \
  -DPKG_EXTRA-MOLECULE=ON \
  -DPKG_EXTRA-PAIR=ON \
  -DPKG_FEP=ON \
  -DPKG_GPU=OFF \
  -DPKG_GRANULAR=ON \
  -DPKG_KOKKOS=ON \
  -DPKG_KSPACE=ON \
  -DPKG_MANYBODY=ON \
  -DPKG_MC=ON \
  -DPKG_MEAM=ON \
  -DPKG_MISC=ON \
  -DPKG_ML-SNAP=ON \
  -DPKG_ML-PACE=OFF \
  -DPKG_MOLECULE=ON \
  -DPKG_OPENMP=ON \
  -DPKG_OPT=ON \
  -DPKG_PERI=ON \
  -DPKG_PHONON=ON \
  -DPKG_PLUGIN=ON \
  -DPKG_REAXFF=ON \
  -DPKG_REPLICA=ON \
  -DPKG_RIGID=ON \
  -DPKG_SHOCK=ON \
  -DPKG_SRD=ON \
  -DSYMMETRIX_KOKKOS=ON \
  -DSYMMETRIX_HOST_ARCH=none \
  -DSYMMETRIX_NLOHMANN_JSON_INCLUDE_DIR="${PREFIX}/include" \
  -DSYMMETRIX_BLAS_LIBRARY="${PREFIX}/lib/libblas.so" \
  -DSYMMETRIX_BLAS_INCLUDE_DIR="${symmetrix_source}/libsymmetrix/external/cblas-prototypes" \
  -DSYMMETRIX_SPHERICART_CUDA=OFF \
  -DSPHERICART_ENABLE_CUDA=OFF \
  -DSPHERICART_OPENMP=ON \
  -DKokkos_ENABLE_CUDA=OFF \
  -DKokkos_ENABLE_HIP=OFF \
  -DKokkos_ENABLE_OPENMP=ON \
  -DKokkos_ENABLE_SERIAL=OFF \
  -DKokkos_ARCH_NATIVE=OFF \
  -DKokkosKernels_INST_DOUBLE=OFF \
  -DKokkosKernels_INST_LAYOUTLEFT=OFF

cmake --build "${build_directory}" --parallel "${CPU_COUNT:-2}"

mkdir -p "${PREFIX}/bin"
install -m 0755 "${build_directory}/lmp" "${PREFIX}/bin/lmp-symmetrix"
"${PREFIX}/bin/mpicxx" -std=c++20 \
  "${symmetrix_source}/tools/mpi_gpu_aware_probe.cpp" \
  -o "${PREFIX}/bin/symmetrix-mpi-gpu-aware-probe"

"${STRIP:-strip}" --strip-unneeded \
  "${PREFIX}/bin/lmp-symmetrix" \
  "${PREFIX}/bin/symmetrix-mpi-gpu-aware-probe"

"${PREFIX}/bin/lmp-symmetrix" -help > "${SRC_DIR}/lammps-help-cpu.txt"
grep -q 'symmetrix/mace' "${SRC_DIR}/lammps-help-cpu.txt"
grep -q 'symmetrix/timing' "${SRC_DIR}/lammps-help-cpu.txt"
