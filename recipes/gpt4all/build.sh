set -exo pipefail

pushd gpt4all-backend

if [[ ${target_platform} == "linux-"* ]]; then
    cmake -S . -B build \
        ${CMAKE_ARGS} \
        -DGGML_OPENMP=ON \
        -DLLMODEL_CUDA=OFF \
        -DLLMODEL_VULKAN=OFF
elif [[ ${target_platform} == "osx-"* ]]; then
    cmake -S . -B build \
        ${CMAKE_ARGS} \
        -DGGML_OPENMP=ON \
        -DLLMODEL_METAL=ON
fi

ctest --test-dir build
popd

pushd gpt4all-bindings/python
pip install .
popd
