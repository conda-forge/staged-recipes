mkdir build
cd build

cmake .. -DCMAKE_INSTALL_PREFIX=$PREFIX \
		 -DBUILD_EXE=ON \
		 -DBUILD_BINDINGS=OFF \
		 -DLINK_STATIC=ON

make -j${CPU_COUNT}
make install
