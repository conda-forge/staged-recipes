mkdir -p build

pushd build

cmake .. \
      -DCMAKE_INSTALL_PREFIX=$PREFIX \
      -DCMAKE_PREFIX_PATH=$PREFIX \
      -DUSE_CXX14_IF_AVAILABLE=ON \
      -DGOOGLE_TEST=OFF \
      -DUSE_OPENMP=ON \
      -DINSTALL_DOCUMENTATION=OFF \
      -DUSE_HDFS=OFF 

make -j$CPU_COUNT
make install
