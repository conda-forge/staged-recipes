cmake -B build -S $SRC_DIR -DBUILD_SHARED_LIBS=YES -DENABLE_TESTS:BOOL=ON \
      $CMAKE_ARGS
cmake --build build --parallel ${CPU_COUNT}
cd build/Tests
ctest
ln -s $SRC_DIR/Tests/plouf.nc
./test_netcdf95
cd ..
cmake --install build
