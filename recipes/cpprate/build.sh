export DESTDIR=$PREFIX
mkdir build
cd build
cmake -DCMAKE_BUILD_EXECUTABLE=1 ..
make -j
make install
