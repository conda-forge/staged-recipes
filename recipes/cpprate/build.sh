mkdir build
cd build
cmake -DCMAKE_BUILD_EXECUTABLE=1 ..
make -j
cmake --install .. --prefix $PREFIX
