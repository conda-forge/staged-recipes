set -ex

cd build
cmake ${CMAKE_ARGS} \
    -DCMAKE_PREFIX_PATH="${PREFIX}" \
    -DCMAKE_INSTALL_PREFIX="${PREFIX}" \
    -DJPEGXL_ENABLE_TOOLS=OFF \
    ..
cmake --build . -j$(nprocs) --target install
