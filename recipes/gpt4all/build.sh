set -exo pipefail

pushd gpt4all-backend

if [[ ${target_platform} == "linux-"* ]]; then
    cmake -S . -B build \
        ${CMAKE_ARGS} \
        -DLLMODEL_KOMPUTE=OFF \
        -DLLMODEL_VULKAN=ON \
        -DLLMODEL_CUDA=OFF \
        -DLLMODEL_ROCM=OFF
elif [[ ${target_platform} == "osx-"* ]]; then
    cmake -S . -B build ${CMAKE_ARGS}
fi

pushd gpt4all-bindings/python
${PYTHON} -m pip install . -vv --no-deps --no-build-isolation
popd
