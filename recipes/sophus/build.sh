mkdir -p build
cd build
cmake -DCMAKE_INSTALL_PREFIX=${PREFIX} \
	  -DCMAKE_PREFIX_PATH=${PREFIX} \
      -DBUILD_SOPHUS_EXAMPLES=OFF \
      -DBUILD_SOPHUS_TEST=OFF \
      -DSOPHUS_USE_BASIC_LOGGING=OFF \
	  ..
make -j${CPU_COUNT}
make install