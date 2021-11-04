mkdir TangoAccessControl/build
cd TangoAccessControl/build
cmake ${CMAKE_ARGS} \
      -DCMAKE_BUILD_TYPE=Release \
      -DCMAKE_VERBOSE_MAKEFILE=true \
      -DMYSQL_INCLUDE_DIR=$PREFIX/include/mysql \
      ..

make -j $CPU_COUNT
make install
