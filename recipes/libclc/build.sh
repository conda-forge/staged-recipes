mkdir build
cd build

cmake \
	${CMAKE_ARGS} \
	-DCMAKE_BUILD_TYPE=Release \
	-DCMAKE_MODULE_PATH=${PREFIX}/lib/cmake/llvm \
	-DCMAKE_FIND_ROOT_PATH_MODE_INCLUDE=BOTH \
	..

make -j${CPU_COUNT}
make install
