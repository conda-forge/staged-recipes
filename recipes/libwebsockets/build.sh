mkdir -p build
cd build
cmake -DCMAKE_INSTALL_PREFIX=${PREFIX} \
      -DCMAKE_PREFIX_PATH=${PREFIX} \
      -DLWS_UNIX_SOCK=ON \
      -DLWS_WITH_STATIC=OFF \
      -DLWS_WITHOUT_TESTAPPS=ON \
      -DLWS_WITH_HTTP_PROXY=ON \
      -DLWS_WITH_ACCESS_LOG=ON \
      -DLWS_WITH_LIBUV=ON \
      -DLWS_WITH_SERVER_STATUS=ON \
      ..

make -j ${CPU_COUNT}
make install
