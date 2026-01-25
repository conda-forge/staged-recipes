set -exo pipefail

pushd gpt4all-backend

if [[ ${target_platform} == "linux-"* ]]; then
    if [[ ${cuda_compiler_version} != "None" ]]; then
        cmake -S . -B build \
            ${CMAKE_ARGS} \
            -DLLMODEL_KOMPUTE=ON \
            -DLLMODEL_VULKAN=OFF \
            -DLLMODEL_CUDA=ON \
            -DLLMODEL_ROCM=OFF \
            -DKOMPUTE_OPT_DISABLE_VULKAN_VERSION_CHECK=ON
    else
        cmake -S . -B build \
            ${CMAKE_ARGS} \
            -DLLMODEL_KOMPUTE=ON \
            -DLLMODEL_VULKAN=OFF \
            -DLLMODEL_CUDA=OFF \
            -DLLMODEL_ROCM=OFF \
            -DKOMPUTE_OPT_DISABLE_VULKAN_VERSION_CHECK=ON
    fi

    pushd "${SRC_DIR}/gpt4all-backend/deps/llama.cpp-mainline"
    make GGML_VULKAN=1 vulkan-shaders-gen
    ./vulkan-shaders-gen \
        --glslc glslc \
        --input-dir ggml/src/vulkan-shaders \
        --target-hpp ggml/src/ggml-vulkan-shaders.hpp \
        --target-cpp ggml/src/ggml-vulkan-shaders.cpp
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
