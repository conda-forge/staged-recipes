#!/usr/bin/env bash
set -ex

if [[ "${target_platform}" == osx-* ]]; then
  export CXXFLAGS="${CXXFLAGS} -D_LIBCPP_DISABLE_AVAILABILITY"
fi

if [[ "${cuda_compiler_version:-None}" != "None" ]]; then
  OCCA_ENABLE_CUDA=ON
else
  OCCA_ENABLE_CUDA=OFF
fi

# HIP and DPC++ need vendor toolkits that are not part of this build; disable
# them explicitly so the result does not depend on what happens to be found on
# the build machine.
cmake -S . -B build -G Ninja \
  ${CMAKE_ARGS} \
  -DCMAKE_BUILD_TYPE=Release \
  -DCMAKE_INSTALL_PREFIX="${PREFIX}" \
  -DOCCA_ENABLE_OPENMP=ON \
  -DOCCA_ENABLE_OPENCL=ON \
  -DOCCA_ENABLE_CUDA=${OCCA_ENABLE_CUDA} \
  -DOCCA_ENABLE_HIP=OFF \
  -DOCCA_ENABLE_DPCPP=OFF \
  -DOCCA_ENABLE_METAL=OFF \
  -DOCCA_ENABLE_FORTRAN=OFF \
  -DOCCA_ENABLE_EXAMPLES=OFF \
  -DOCCA_ENABLE_TESTS=ON

if [[ "${OCCA_ENABLE_CUDA}" == "ON" ]] && ! grep -q "OCCA_CUDA_ENABLED 1" build/include/occa/defines/compiledDefines.hpp; then
  echo "CUDA build requested but OCCA did not find the CUDA toolkit" >&2
  exit 1
fi

cmake --build build --parallel "${CPU_COUNT}"
cmake --install build

# Run after installing, so kernels are JIT-compiled against the installed
# headers. The unit tests also read fixtures from $OCCA_DIR/tests, so give
# them an OCCA_DIR combining the installed include/ with the source tests/.
if [[ "${CONDA_BUILD_CROSS_COMPILATION:-}" != "1" ]]; then
  # Without an NVIDIA driver (e.g. on CI), load the stub libcuda so the tests
  # can be loaded; CUDA mode then reports itself as unavailable.
  if [[ "${OCCA_ENABLE_CUDA}" == "ON" ]] && ! ldconfig -p 2>/dev/null | grep -q 'libcuda\.so\.1 '; then
    mkdir -p build/cuda-stub
    ln -sf "${PREFIX}/lib/stubs/libcuda.so" build/cuda-stub/libcuda.so.1
    export LD_LIBRARY_PATH="${PWD}/build/cuda-stub${LD_LIBRARY_PATH:+:${LD_LIBRARY_PATH}}"
  fi
  mkdir -p build/occa-dir
  ln -sfn "${PREFIX}/include" build/occa-dir/include
  ln -sfn "${SRC_DIR}/tests" build/occa-dir/tests
  # The sys test asserts that $HOME is not safe to delete, which fails when
  # $HOME has an "occa" path component; rattler-build sets HOME=$SRC_DIR, so
  # building under e.g. recipes/occa/output/ trips it. Give the tests a HOME
  # outside the build tree and keep OCCA's kernel cache in the build directory.
  ctest_home="$(mktemp -d /tmp/ctest-home.XXXXXX)"
  # Serial: parallel tests race on OCCA's shared cache (compiler-vendor probe)
  HOME="${ctest_home}" OCCA_CACHE_DIR="${PWD}/build/occa-cache" \
    OCCA_DIR="${PWD}/build/occa-dir" ctest --test-dir build --output-on-failure
  rm -rf "${ctest_home}"
fi

# Environment-modules file; not useful inside a conda environment
rm -rf "${PREFIX}/modulefiles"
