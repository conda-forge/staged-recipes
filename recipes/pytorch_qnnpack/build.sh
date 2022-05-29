if [[ ! -d "pytorch_qnnpack" ]]; then
    mv pytorch/aten/src/ATen/native/quantized/cpu/qnnpack pytorch_qnnpack
    rm -rf pytorch
fi

cd pytorch_qnnpack

mkdir build
cd build
cmake ${CMAKE_ARGS}                \
    -DCMAKE_BUILD_TYPE=Release     \
    -DPYTORCH_QNNPACK_BUILD_TESTS=OFF      \
    -DPYTORCH_QNNPACK_BUILD_BENCHMARKS=OFF \
    -DPYTORCH_QNNPACK_LIBRARY_TYPE=shared  \
    -DPYTORCH_QNNPACK_USE_SYSTEM_LIBS=ON   \
    ..
make -j${CPU_COUNT}
make install
