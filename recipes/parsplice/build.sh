mkdir build
cd build
export CFLAGS="${CFLAGS} -llammps -ldb"
cmake -DCMAKE_PREFIX_PATH="${PREFIX}"  -DCMAKE_INSTALL_PREFIX="${PREFIX}" ../ 
make -j${CPU_COUNT}
make install
