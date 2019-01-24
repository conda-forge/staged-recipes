mkdir build
cd build
CMAKE_FLAGS="-DCMAKE_INSTALL_PREFIX=${PREFIX}"
cmake ${CMAKE_FLAGS} ..
make
make install 

