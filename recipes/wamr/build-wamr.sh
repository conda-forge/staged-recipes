#!/usr/bin/env bash
set -euxo pipefail

profile="${1:-}"
case "${profile}" in
  interp|aot|jit|compiler)
    ;;
  *)
    echo "Unsupported WAMR profile: ${profile}" >&2
    exit 1
    ;;
esac

make_jit_llvm_config() {
  local config_dir="${BUILD_PREFIX}/freecad-wamr-llvm-config"
  mkdir -p "${config_dir}"
  printf '%s\n' \
    "include(\"${PREFIX}/lib/cmake/llvm/LLVMConfig.cmake\")" \
    'set(LLVM_AVAILABLE_LIBS LLVM)' \
    > "${config_dir}/LLVMConfig.cmake"
  printf '%s\n' \
    'set(PACKAGE_VERSION "0")' \
    > "${config_dir}/LLVMConfigVersion.cmake"
  printf '%s' "${config_dir}"
}

if [[ "${profile}" == compiler ]]; then
  cmake_args=(
    -S wamr-compiler -B build -G Ninja
    -DCMAKE_BUILD_TYPE=Release
    -DCMAKE_INSTALL_PREFIX="${PREFIX}"
    -DWAMR_BUILD_WITH_CUSTOM_LLVM=1
    -DLLVM_DIR="${PREFIX}/lib/cmake/llvm"
  )
  if [[ -n "${CMAKE_ARGS:-}" ]]; then
    cmake_args+=( ${CMAKE_ARGS} )
  fi
  cmake "${cmake_args[@]}"
else
  fast_interp=0
  aot=0
  jit=0
  instruction_metering=1

  case "${profile}" in
    aot)
      fast_interp=1
      aot=1
      instruction_metering=0
      ;;
    jit)
      fast_interp=0
      aot=1
      jit=1
      instruction_metering=0
      ;;
  esac

  cmake_args=(
    -S . -B build -G Ninja
    -DCMAKE_BUILD_TYPE=Release
    -DCMAKE_INSTALL_PREFIX="${PREFIX}"
    -DBUILD_SHARED_LIBS=ON
    -DWAMR_BUILD_INTERP=1
    -DWAMR_BUILD_FAST_INTERP="${fast_interp}"
    -DWAMR_BUILD_AOT="${aot}"
    -DWAMR_BUILD_JIT="${jit}"
    -DWAMR_BUILD_FAST_JIT=0
    -DWAMR_BUILD_LIBC_BUILTIN=1
    -DWAMR_BUILD_LIBC_WASI=0
    -DWAMR_BUILD_MULTI_MODULE=0
    -DWAMR_BUILD_BULK_MEMORY=1
    -DWAMR_BUILD_SHARED_MEMORY=0
    -DWAMR_BUILD_THREAD_MGR=0
    -DWAMR_BUILD_LIB_PTHREAD=0
    -DWAMR_BUILD_LIB_WASI_THREADS=0
    -DWAMR_BUILD_MINI_LOADER=0
    -DWAMR_BUILD_SIMD=1
    -DWAMR_BUILD_REF_TYPES=1
    -DWAMR_BUILD_MEMORY64=0
    -DWAMR_BUILD_MULTI_MEMORY=0
    -DWAMR_BUILD_INSTRUCTION_METERING="${instruction_metering}"
  )
  if [[ "${profile}" == jit ]]; then
    cmake_args+=("-DLLVM_DIR=$(make_jit_llvm_config)")
  fi
  if [[ -n "${CMAKE_ARGS:-}" ]]; then
    cmake_args+=( ${CMAKE_ARGS} )
  fi
  cmake "${cmake_args[@]}"
fi

cmake --build build --target install --parallel
