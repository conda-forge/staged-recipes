#!/bin/bash
set -euxo pipefail

EXTRA_CMAKE_ARGS=()

if [[ "${CONDA_BUILD_CROSS_COMPILATION:-0}" == "1" ]]; then
  # mlir_builder_tblgen is built and run during the build, so build a native
  # copy first against the MLIR in BUILD_PREFIX.
  (
    unset CFLAGS CXXFLAGS CPPFLAGS LDFLAGS
    cmake -S "${SRC_DIR}" -B build-native -G Ninja \
      -DCMAKE_BUILD_TYPE=Release \
      -DCMAKE_C_COMPILER="${CC_FOR_BUILD}" \
      -DCMAKE_CXX_COMPILER="${CXX_FOR_BUILD}" \
      -DCMAKE_PREFIX_PATH="${BUILD_PREFIX}" \
      -DMLIR_DIR="${BUILD_PREFIX}/lib/cmake/mlir" \
      -DLLVM_DIR="${BUILD_PREFIX}/lib/cmake/llvm"
    cmake --build build-native --target mlir_builder_tblgen
  )
  EXTRA_CMAKE_ARGS+=(
    -DMLIR_NATIVE_TOOLS_DIR="${BUILD_PREFIX}/bin"
    -DMLIR_BUILDER_TABLEGEN="${SRC_DIR}/build-native/bin/mlir_builder_tblgen"
    -DMLIR_BUILDER_TABLEGEN_EXE="${SRC_DIR}/build-native/bin/mlir_builder_tblgen"
  )
fi

cmake -S "${SRC_DIR}" -B build -G Ninja ${CMAKE_ARGS} \
  -DCMAKE_BUILD_TYPE=Release \
  -DCMAKE_INSTALL_PREFIX="${PREFIX}" \
  -DMLIR_DIR="${PREFIX}/lib/cmake/mlir" \
  -DLLVM_DIR="${PREFIX}/lib/cmake/llvm" \
  -DLLVM_ENABLE_ASSERTIONS=OFF \
  -DSTABLEHLO_ENABLE_BINDINGS_PYTHON=OFF \
  "${EXTRA_CMAKE_ARGS[@]}"

cmake --build build

# Installs the static libraries.
cmake --install build
rm -rf "${PREFIX}/lib/objects-Release"

# Upstream has no install rules for the tools or headers.
install -d "${PREFIX}/bin"
for tool in stablehlo-opt stablehlo-translate stablehlo-lsp-server; do
  install -m 755 "build/bin/${tool}" "${PREFIX}/bin/${tool}"
done

# Source headers plus tablegen-generated headers, keeping the
# "stablehlo/..." include paths used by the headers themselves.
(cd "${SRC_DIR}" && find stablehlo -name '*.h' -not -path '*/tests/*' -print0 \
  | xargs -0 -I{} install -D -m 644 {} "${PREFIX}/include/{}")
(cd build && find stablehlo \( -name '*.h' -o -name '*.h.inc' \) -not -path '*/tests/*' -not -path '*/CMakeFiles/*' -print0 \
  | xargs -0 -I{} install -D -m 644 {} "${PREFIX}/include/{}")
