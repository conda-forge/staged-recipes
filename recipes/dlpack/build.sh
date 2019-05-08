cmake 	-DCMAKE_BUILD_TYPE=Release \
	-DCMAKE_INSTALL_PREFIX=$PREFIX \
	-DCMAKE_PREFIX_PATH=$PREFIX \
	-DBUILD_DOCS=OFF \
	-DCMAKE_INSTALL_LIBDIR=$PREFIX/lib

make -j$CPU_COUNT

mkdir -p $PREFIX/include/dlpack
cp include/dlpack/*.h $PREFIX/include/dlpack/.
cp bin/mock $PREFIX/bin/.



