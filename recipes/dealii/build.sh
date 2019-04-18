mkdir build
cd build

cmake -DCMAKE_INSTALL_PREFIX="${PREFIX}" \
      -DDEAL_II_WITH_THREADS=OFF \
      ..

make -j${CPU_COUNT}
make install
make test
