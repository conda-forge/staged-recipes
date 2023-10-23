mkdir build
pushd build
cmake ${CMAKE_ARGS} -DCMAKE_BUILD_EXECUTABLE=1 ..
make -j${CPU_COUNT}
popd

install -d $PREFIX/bin
install build/bin/cpprate $PREFIX/bin
