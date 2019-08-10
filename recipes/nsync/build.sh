mkdir -p out
cd out
cmake -DCMAKE_INSTALL_PREFIX=${PREFIX} \
	  -DCMAKE_PREFIX_PATH=${PREFIX} \
	  -DCMAKE_EXE_LINKER_FLAGS="-pthread -lrt" \
	  -DCMAKE_INSTALL_LIBDIR=lib \
	  ..
make -j${CPU_COUNT}
make install
