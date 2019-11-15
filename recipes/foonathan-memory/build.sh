mkdir build
cd build

cmake .. \
      -G "Ninja" \
      -DCMAKE_BUILD_TYPE=Release \
      -DCMAKE_PREFIX_PATH=$PREFIX -DCMAKE_INSTALL_PREFIX=$PREFIX \
      -DCMAKE_INSTALL_LIBDIR=lib \
      -DCMAKE_INSTALL_SYSTEM_RUNTIME_LIBS_SKIP=ON \
      -DCMAKE_POSITION_INDEPENDENT_CODE=ON \
      -DFOONATHAN_MEMORY_BUILD_EXAMPLES=OFF \
      -DFOONATHAN_MEMORY_BUILD_TESTS=OFF \
      -DFOONATHAN_MEMORY_BUILD_TOOLS=ON \
      -DBUILD_SHARED_LIBS=ON

cmake --build . --config Release -- -j$CPU_COUNT
cmake --build . --config Release --target install
