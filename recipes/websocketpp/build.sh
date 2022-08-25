mkdir build
cd build

cmake ${CMAKE_ARGS} .. \
      -G "Ninja" \
      -DCMAKE_BUILD_TYPE=Release \
      -DCMAKE_PREFIX_PATH=$PREFIX \
      -DCMAKE_INSTALL_PREFIX=$PREFIX \
      -DCMAKE_INSTALL_LIBDIR=lib \
      -DBoost_NO_BOOST_CMAKE=OFF

cmake --build . --config Release -- -j$CPU_COUNT
cmake --build . --config Release --target install
