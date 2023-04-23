mkdir -p build
cd build
cmake ${CMAKE_ARGS} \
      -DCMAKE_INSTALL_PREFIX=${PREFIX} \
      -DCMAKE_PREFIX_PATH=${PREFIX} \
      -DOPENVDB_CORE_SHARED=ON \
      -DOPENVDB_CORE_STATIC=OFF \
      -DUSE_EXPLICIT_INSTANTIATION=OFF \
      ..
make -j${CPU_COUNT}
make install