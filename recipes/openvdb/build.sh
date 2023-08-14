mkdir -p build
cd build
cmake ${CMAKE_ARGS} \
      -DOPENVDB_CORE_SHARED=ON \
      -DOPENVDB_CORE_STATIC=OFF \
      -DUSE_EXPLICIT_INSTANTIATION=OFF \
      ..
cmake --build . --target install --parallel
