mkdir build
cd build

cmake .. \
      -G "Ninja" \
      -DCMAKE_BUILD_TYPE=Release \
      -DCMAKE_PREFIX_PATH=$PREFIX -DCMAKE_INSTALL_PREFIX=$PREFIX \
      -DCMAKE_INSTALL_LIBDIR=lib \
      -DCMAKE_INSTALL_SYSTEM_RUNTIME_LIBS_SKIP=ON \
      -DCMAKE_POSITION_INDEPENDENT_CODE=ON \
      -DBUILD_SHARED_LIBS=ON

cmake --build . --config Release -- -j$CPU_COUNT
cmake --build . --config Release --target install

rm -rf $PREFIX/man1
