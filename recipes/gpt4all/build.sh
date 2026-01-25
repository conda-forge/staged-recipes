set -exo pipefail

pushd gpt4all-backend

if [[ ${target_platform} == "linux-"* ]]; then
    if [[ ${cuda_compiler_version} != "None" ]]; then
        cmake -S . -B build \
            ${CMAKE_ARGS} \
            -DLLMODEL_KOMPUTE=ON \
            -DLLMODEL_VULKAN=ON \
            -DLLMODEL_CUDA=ON \
            -DLLMODEL_ROCM=OFF \
            -DVulkan_GLSLC_EXECUTABLE="${BUILD_PREFIX}/bin/glslc" \
            -DKOMPUTE_OPT_DISABLE_VULKAN_VERSION_CHECK=ON
    else
        cmake -S . -B build \
            ${CMAKE_ARGS} \
            -DLLMODEL_KOMPUTE=ON \
            -DLLMODEL_VULKAN=ON \
            -DLLMODEL_CUDA=OFF \
            -DLLMODEL_ROCM=OFF \
            -DVulkan_GLSLC_EXECUTABLE="${BUILD_PREFIX}/bin/glslc" \
            -DKOMPUTE_OPT_DISABLE_VULKAN_VERSION_CHECK=ON
    fi

    # Build vulkan-shaders to generate shaders before the main build
    pushd "${SRC_DIR}/gpt4all-backend/deps/llama.cpp-mainline/ggml/src/vulkan-shaders"
    cmake -S . -B build ${CMAKE_ARGS}
    echo "Building vulkan-shaders subproject"
    cmake --build build --parallel ${CPU_COUNT}

    # Generated files that the generator will write
    GEN_HDR="${SRC_DIR}/gpt4all-backend/deps/llama.cpp-mainline/ggml/src/ggml-vulkan-shaders.hpp"
    GEN_CPP="${SRC_DIR}/gpt4all-backend/deps/llama.cpp-mainline/ggml/src/ggml-vulkan-shaders.cpp"

    # Use a directory (not a filename) for SPIR-V output
    OUT_DIR="${PWD}/build/vulkan-spv"
    mkdir -p "$OUT_DIR"

    # Find the generated tool in the subbuild (locations may vary by generator/platform)
    GEN_TOOL=$(find build -type f -name 'vulkan-shaders-gen*' -executable -print -quit || true)
    if [[ -n "$GEN_TOOL" ]]; then
        echo "Running ${GEN_TOOL} to generate shaders"

        # Prefer the build-provided glslc, fall back to PATH
        GLSLC="${BUILD_PREFIX}/bin/glslc"

        "${GEN_TOOL}" \
            --glslc "$GLSLC" \
            --input-dir "${SRC_DIR}/gpt4all-backend/deps/llama.cpp-mainline/ggml/src/vulkan-shaders" \
            --output-dir "$OUT_DIR" \
            --target-hpp "$GEN_HDR" \
            --target-cpp "$GEN_CPP" \
            --no-clean
    else
        echo "vulkan-shaders-gen not produced by subbuild; continuing (build may fail)"
    fi
    popd
elif [[ ${target_platform} == "osx-64" ]]; then
    cmake -S . -B build \
        ${CMAKE_ARGS} \
        -DBUILD_UNIVERSAL=OFF
elif [[ ${target_platform} == "osx-arm64" ]]; then
    cmake -S . -B build \
        ${CMAKE_ARGS} \
        -DBUILD_UNIVERSAL=OFF
fi

cmake --build build --parallel ${CPU_COUNT}
popd

pushd gpt4all-bindings/python
${PYTHON} -m pip install . -vv --no-deps --no-build-isolation
popd
