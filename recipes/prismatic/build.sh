

mkdir build && cd build 

cmake -D PRISMATIC_ENABLE_GUI=1 \
	-D CMAKE_INSTALL_PREFIX=$PREFIX \
	../ 

make  -j${CPU_COUNT}

make install
