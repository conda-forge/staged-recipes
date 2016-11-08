mkdir -p build
cd build
cmake -DBUILD_SHARED_LIBS=ON \
      -DCMAKE_BUILD_TYPE=Release \
      -DCMAKE_INSTALL_PREFIX=%PREFIX% \
      ..
make -j %CPU_COUNT%
make -j %CPU_COUNT% test
make -j %CPU_COUNT% install
