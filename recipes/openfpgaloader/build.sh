mkdir build
cd build

cmake \
  ${CMAKE_ARGS} \
  -DENABLE_CMSISDAP=OFF  \
  -DENABLE_REMOTEBITBANG=OFF \
  ..

make -j${CPU_COUNT}
make install
