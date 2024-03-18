mkdir build
cd build

cmake ${CMAKE_ARGS} .. \
      -DCMAKE_BUILD_TYPE=Release \
      -DCMAKE_PREFIX_PATH=$PREFIX \
      -DCMAKE_INSTALL_PREFIX=$PREFIX \
      -DCMAKE_INSTALL_LIBDIR=lib \
      -Dnanobind_DIR=$SP_DIR/nanobind/cmake \
      -DUSE_PYTHON=1

cmake --build . --config Release -- -j$CPU_COUNT
cmake --build . --config Release --target install
