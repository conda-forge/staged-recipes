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

cmake --build build --parallel 1
popd

pushd gpt4all-bindings/python
${PYTHON} -m pip install . -vv --no-deps --no-build-isolation
popd
