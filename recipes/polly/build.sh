cd polly
mkdir -p build && cd build
cmake -DCMAKE_BUILD_TYPE="Release" -DLLVM_ENABLE_PIC=1 -DCMAKE_INSTALL_PREFIX=${PREFIX} ..
make -j${CPU_COUNT}
make install
