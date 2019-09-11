mkdir source/build
cd source/build
cmake -D TENSORFLOW_ROOT=${PREFIX} \
	  -D CMAKE_INSTALL_PREFIX=${PREFIX} \
	  ..
make -j${CPU_COUNT}
make install
