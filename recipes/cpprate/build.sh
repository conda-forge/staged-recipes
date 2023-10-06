mkdir build
pushd build
cmake -DCMAKE_BUILD_EXECUTABLE=1 ..
make -j
popd

install -d $PREFIX/bin
install build/bin/cpprate $PREFIX/bin
