mkdir build && cd build

cmake -G"$CMAKE_GENERATOR" -DCMAKE_BUILD_TYPE=Release \
      -DCMAKE_INSTALL_PREFIX="$PREFIX" \
      ${SRC_DIR}

cmake --build . --config Release --target install
