#!/bin/bash
# Build script of the conda package alexandria, see recipe.yaml
set -euxo pipefail

case "${target_platform}" in
    osx-arm64|linux-aarch64) SIMD=ARM_NEON ;;
    linux-64)                SIMD=AVX2 ;;
    *)                       SIMD=NONE ;;
esac

case "${ACT_GPU_VARIANT:-none}" in
    sycl_*) GPU="-DACT_GPU=SYCL -DAdaptiveCpp_DIR=${PREFIX}/lib/cmake/AdaptiveCpp" ;;
    *)      GPU="-DACT_GPU=NONE" ;;
esac

# Warnings are errors in the ACT build, which is good for development, but a
# newer compiler or library should not stop the package from building.
cmake ${CMAKE_ARGS} --compile-no-warning-as-error -S . -B build \
    -DCMAKE_BUILD_TYPE=Release \
    -DCMAKE_INSTALL_PREFIX="${PREFIX}" \
    -DCMAKE_PREFIX_PATH="${PREFIX}" \
    -DPython3_EXECUTABLE="${PREFIX}/bin/python" \
    -DBUILD_SHARED_LIBS=ON \
    -DACT_MPI=ON \
    -DACT_SIMD=${SIMD} \
    ${GPU} \
    -DACT_OPENMP=OFF \
    -DACT_DOUBLE=OFF \
    -DACT_BUILD_TARBALL=ON

cmake --build build --parallel ${CPU_COUNT}

if [[ "${CONDA_BUILD_CROSS_COMPILATION:-0}" != "1" ]]; then
    # The test programs are not part of the default target
    cmake --build build --parallel ${CPU_COUNT} --target tests
    # MPICH of conda-forge uses UCX, which may fail to open the network
    # devices of a build machine, for instance on the GitHub runners. The tests
    # run on one machine, which needs only shared memory and TCP.
    (cd build && UCX_TLS=self,sm,tcp ctest --output-on-failure --parallel ${CPU_COUNT})
fi

cmake --install build
