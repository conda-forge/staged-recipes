mkdir build
cd build

autoreconf -fi
./configure
make -j 8
make install
