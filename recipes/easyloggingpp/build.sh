mkdir build
cd build
cmake -DCMAKE_INSTALL_PREFIX=$PREFIX -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_LIBDIR=lib -DBUILD_SHARED_LIBS=ON -Dtest=ON ../
make -j  ${CPU_COUNT}
make test
make install
