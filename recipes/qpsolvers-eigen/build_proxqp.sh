rm -rf build_proxqp
mkdir build_proxqp
cd build_proxqp

# The enable options are set to OFF as each plugins is built as its own package
cmake ${CMAKE_ARGS} -GNinja \
      -DCMAKE_BUILD_TYPE=Release \
      -DBUILD_TESTING:BOOL=ON \
      ${SRC_DIR}/plugins/proxqp

cmake --build . --config Release

cmake --build . --config Release --target install
