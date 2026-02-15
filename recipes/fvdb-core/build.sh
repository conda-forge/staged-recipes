#!/bin/bash

setup_parallel_build_jobs() {
  # Calculate the optimal number of parallel build jobs based on available RAM
  RAM_GB=$(free -g | awk '/^Mem:/{print $7}')
  if [ -z "$RAM_GB" ]; then
      echo "Error: Unable to determine available RAM"
      exit 1
  fi
  JOB_RAM_GB=3

  # Get number of processors
  NPROC=$(nproc)

  # count the number of ';' in the TORCH_CUDA_ARCH_LIST
  NUM_ARCH=$(echo "$TORCH_CUDA_ARCH_LIST" | tr ';' '\n' | wc -l)
  if [ "$NUM_ARCH" -lt 1 ]; then
    NUM_ARCH=1
  fi
  NVCC_THREADS=$NUM_ARCH

  # Check if we have enough RAM for even one job with full NVCC_THREADS
  # Requirement: JOB_RAM_GB * NVCC_THREADS
  MIN_RAM_REQUIRED=$((JOB_RAM_GB * NVCC_THREADS))

  if [ "$RAM_GB" -lt "$MIN_RAM_REQUIRED" ]; then
      NVCC_THREADS=1
  fi

  # Limit NVCC_THREADS to NPROC to ensure we don't oversubscribe
  if [ "$NVCC_THREADS" -gt "$NPROC" ]; then
      NVCC_THREADS=$NPROC
  fi

  # Determine max jobs based on CPU:
  # We want CMAKE_BUILD_PARALLEL_LEVEL * NVCC_THREADS <= NPROC
  MAX_JOBS_CPU=$((NPROC / NVCC_THREADS))

  # Determine max jobs based on RAM:
  # Assume each job requires JOB_RAM_GB * NVCC_THREADS
  MAX_JOBS_RAM=$((RAM_GB / (JOB_RAM_GB * NVCC_THREADS)))

  # Take the minimum
  PARALLEL_JOBS=$((MAX_JOBS_CPU < MAX_JOBS_RAM ? MAX_JOBS_CPU : MAX_JOBS_RAM))

  # Ensure at least 1 job
  if [ "$PARALLEL_JOBS" -lt 1 ]; then
    PARALLEL_JOBS=1
  fi

  # if CMAKE_BUILD_PARALLEL_LEVEL is set, use that
  if [ -n "$CMAKE_BUILD_PARALLEL_LEVEL" ]; then
    echo "Using CMAKE_BUILD_PARALLEL_LEVEL=$CMAKE_BUILD_PARALLEL_LEVEL"
  else

    CMAKE_BUILD_PARALLEL_LEVEL=$PARALLEL_JOBS

    echo "Setting nvcc --threads to $NVCC_THREADS based on the number of CUDA architectures ($NUM_ARCH)"
    echo "Setting CMAKE_BUILD_PARALLEL_LEVEL to $CMAKE_BUILD_PARALLEL_LEVEL"
    echo "  Constraint: Total Threads ($((CMAKE_BUILD_PARALLEL_LEVEL * NVCC_THREADS))) <= NPROC ($NPROC)"
    echo "  Constraint: Estimated RAM ($((CMAKE_BUILD_PARALLEL_LEVEL * NVCC_THREADS * JOB_RAM_GB))) GB <= Available RAM ($RAM_GB GB)"

    export CMAKE_BUILD_PARALLEL_LEVEL
    export NVCC_THREADS
  fi
}


setup_parallel_build_jobs
export CMAKE_GENERATOR=Ninja
# GCC 14 false positive: -Wstringop-overflow in NanoVDB headers with deep template inlining at -O3
# See: https://gcc.gnu.org/bugzilla/show_bug.cgi?id=118817
export CXXFLAGS="${CXXFLAGS} -Wno-error=stringop-overflow"
$PYTHON -m pip install \
    --no-deps \
    --no-build-isolation \
    -vv \
    -C 'skbuild.ninja.make-fallback=false' \
    .
