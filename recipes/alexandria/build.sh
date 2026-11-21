#!/bin/bash
# Build script of the conda package alexandria, see recipe.yaml
set -euxo pipefail

case "${target_platform}" in
    osx-arm64|linux-aarch64) SIMD=ARM_NEON ;;
    linux-64)                SIMD=AVX2 ;;
    *)                       SIMD=NONE ;;
esac

GPU=(-DACT_GPU=NONE)
if [[ "${ACT_GPU_VARIANT:-none}" == sycl_* ]]; then
    GPU=(-DACT_GPU=SYCL -DAdaptiveCpp_DIR="${PREFIX}/lib/cmake/AdaptiveCpp")
    if [[ "${target_platform}" == linux-* ]]; then
        # acpp compiles and links libactGpu with the clang of AdaptiveCpp,
        # which has no sysroot of its own and would take the headers and the
        # C library of the build machine or container,
        # so that the package does not run on systems with an older glibc.
        # Give it the sysroot and the GCC (libstdc++) of the conda compiler.
        GCC_DIR=$(dirname "$(${CXX} -print-libgcc-file-name)")
        GPU+=("-DACPP_EXTRA_ARGS=--sysroot=$(${CXX} -print-sysroot) --gcc-install-dir=${GCC_DIR}")
    fi
fi

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
    "${GPU[@]}" \
    -DACT_OPENMP=OFF \
    -DACT_DOUBLE=OFF \
    -DACT_BUILD_TARBALL=ON

cmake --build build --parallel ${CPU_COUNT}

if [[ "${target_platform}" == linux-* ]]; then
    # No library may need a newer glibc than that of the sysroot, which the
    # package requires (__glibc)
    SYSROOT=$(${CXX} -print-sysroot)
    # features.h separates the words with tabs
    LIMIT=$(awk '$1 == "#define" && $2 == "__GLIBC__" {a=$3}
                 $1 == "#define" && $2 == "__GLIBC_MINOR__" {b=$3}
                 END {if (a != "" && b != "") print a "." b}' \
            "${SYSROOT}/usr/include/features.h")
    if [[ -z "${LIMIT}" ]]; then
        echo "No glibc version in ${SYSROOT}/usr/include/features.h"
        exit 1
    fi
    NEEDED=$(for f in build/lib/*.so* build/bin/alexandria; do ${OBJDUMP:-objdump} -T "$f"; done |
             grep -oE 'GLIBC_[0-9]+\.[0-9]+' | sed 's/GLIBC_//' | sort -V -u | tail -1)
    echo "glibc of the sysroot ${LIMIT}, newest needed ${NEEDED}"
    if [[ "$(printf '%s\n%s\n' "${NEEDED}" "${LIMIT}" | sort -V | tail -1)" != "${LIMIT}" ]]; then
        echo "A library needs glibc ${NEEDED}, newer than ${LIMIT} of the sysroot:"
        for f in build/lib/*.so* build/bin/alexandria; do
            ${OBJDUMP:-objdump} -T "$f" | grep -E "GLIBC_${NEEDED}" | sed "s|^|$f: |"
        done
        exit 1
    fi
fi

if [[ "${CONDA_BUILD_CROSS_COMPILATION:-0}" != "1" ]]; then
    # The test programs are not part of the default target
    cmake --build build --parallel ${CPU_COUNT} --target tests
    # MPICH of conda-forge uses UCX, which may fail to open the network
    # devices of a build machine, for instance on the GitHub runners. The tests
    # run on one machine, which needs only shared memory and TCP.
    export UCX_TLS=self,sm,tcp
    # The MPI tests start 4 ranks, which Open MPI only allows on machines with
    # fewer cores with oversubscription (Open MPI 4 and 5); MPICH ignores this
    export OMPI_MCA_rmaps_base_oversubscribe=1
    export PRTE_MCA_rmaps_default_mapping_policy=:oversubscribe
    (cd build && ctest --output-on-failure --parallel ${CPU_COUNT})
fi

cmake --install build
