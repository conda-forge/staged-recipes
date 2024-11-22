rm -rf build_osqp
mkdir build_osqp
cd build_osqp

# The enable options are set to OFF as each plugins is built as its own package
cmake ${CMAKE_ARGS} -GNinja \
      -DCMAKE_BUILD_TYPE=Release \
      -DBUILD_TESTING:BOOL=ON \
      ${SRC_DIR}/plugins/osqp

cmake --build . --config Release

cmake --build . --config Release --target install
