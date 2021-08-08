mkdir build
cd build
cmake ..

make -j${CPU_COUNT}
make install
