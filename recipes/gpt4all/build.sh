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
            -DVulkan_GLSLC_EXECUTABLE="${BUILD_PREFIX}/bin/glslc"
    else
        cmake -S . -B build \
            ${CMAKE_ARGS} \
            -DLLMODEL_KOMPUTE=ON \
            -DLLMODEL_VULKAN=ON \
            -DLLMODEL_CUDA=OFF \
            -DLLMODEL_ROCM=OFF \
            -DVulkan_GLSLC_EXECUTABLE="${BUILD_PREFIX}/bin/glslc"
    fi
elif [[ ${target_platform} == "osx-64" ]]; then
    cmake -S . -B build \
        ${CMAKE_ARGS} \
        -DBUILD_UNIVERSAL=OFF
elif [[ ${target_platform} == "osx-arm64" ]]; then
    cmake -S . -B build \
        ${CMAKE_ARGS} \
        -DBUILD_UNIVERSAL=OFF
fi

# Build and run vulkan-shaders-gen to generate Vulkan shader headers before building everything
# This ensures ggml-vulkan-shaders.hpp / .cpp exist before compiling ggml sources.
cmake --build build --target vulkan-shaders-gen --parallel ${CPU_COUNT} || true

# Locate the built vulkan-shaders-gen executable in common locations
GEN_EXE=""
for p in \
    "${PWD}/build/vulkan-shaders-gen" \
    "${PWD}/build/bin/vulkan-shaders-gen" \
    "${PWD}/build/Debug/vulkan-shaders-gen" \
    "${PWD}/build/Release/vulkan-shaders-gen" \
    "${PWD}/build/bin/Debug/vulkan-shaders-gen" \
    "${PWD}/build/bin/Release/vulkan-shaders-gen"; do
    if [ -x "$p" ]; then
        GEN_EXE="$p"
        break
    fi
done

if [ -n "$GEN_EXE" ]; then
    echo "Running vulkan-shaders-gen: $GEN_EXE"
    "$GEN_EXE" \
        --glslc "${BUILD_PREFIX}/bin/glslc" \
        --input-dir "${SRC_DIR}/gpt4all-backend/deps/llama.cpp-mainline/ggml/src/vulkan-shaders" \
        --output-dir "${PWD}/build/vulkan-shaders.spv" \
        --target-hpp "${PWD}/build/ggml-vulkan-shaders.hpp" \
        --target-cpp "${PWD}/build/ggml-vulkan-shaders.cpp" \
        --no-clean
else
    echo "vulkan-shaders-gen not found; continuing build (may fail if Vulkan is enabled)"
fi

cmake --build build --parallel ${CPU_COUNT}
popd

pushd gpt4all-bindings/python
${PYTHON} -m pip install . -vv --no-deps --no-build-isolation
popd
