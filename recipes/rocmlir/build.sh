#!/bin/bash
set -xeuo pipefail

# CMAKE_ARGS contains separate command-line options.
# shellcheck disable=SC2086
cmake -S . -B build -GNinja \
    ${CMAKE_ARGS} \
    -DROCM_PATH="${PREFIX}" \
    -DLLVM_VERSION_SUFFIX= \
    -DLLVM_APPEND_VC_REV=OFF \
    -DROCMLIR_PARALLEL_LINK_JOBS=1 \
    -DBUILD_FAT_LIBROCKCOMPILER=ON \
    -DROCMLIR_GEN_CPP_FILES=OFF \
    -DMLIR_ENABLE_ROCM_RUNNER=OFF \
    -DMLIR_INCLUDE_INTEGRATION_TESTS=OFF \
    -DROCMLIR_DRIVER_E2E_TEST_ENABLED=OFF \
    -DROCMLIR_DRIVER_PR_E2E_TEST_ENABLED=OFF \
    -DROCK_E2E_TEST_ENABLED=OFF

cmake --build build --parallel "${CPU_COUNT}"
cmake --install build

# Consumers only use the C API, so link one .so and let the linker drop the rest.
cat > rocmlir.map <<'MAP'
ROCMLIR_1 { global: miir*; mlir*; local: *; };
MAP

# LDFLAGS contains separate linker options.
# shellcheck disable=SC2086
"${CXX}" -shared -o "${PREFIX}/lib/librockCompiler.so" \
    -Wl,-soname,librockCompiler.so \
    -Wl,--whole-archive \
        build/lib/libMLIRCAPIRock.a \
        build/lib/libMLIRCAPIMIGraphX.a \
        build/lib/libMLIRCAPIRegisterRocMLIR.a \
        build/lib/libMLIRRockThin.a \
        build/external/llvm-project/llvm/lib/libMLIRCAPIIR.a \
    -Wl,--no-whole-archive \
    build/lib/librockCompiler.a \
    -Wl,--version-script=rocmlir.map \
    ${LDFLAGS} -L"${PREFIX}/lib" -lamdhip64 -lhsa-runtime64

sed -i 's#librockCompiler\.a#librockCompiler.so#' \
    "${PREFIX}/lib/cmake/rocmlir/rocmlir-targets.cmake"
rm "${PREFIX}/lib/librockCompiler.a"

for _a in build/lib/*.a; do
    rm -f "${PREFIX}/lib/$(basename "${_a}")"
done
rm -rf "${PREFIX}/lib/objects-Release"
