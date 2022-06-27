mkdir build
cd build

cmake .. ${CMAKE_ARGS} \
	-GNinja \
	-DCMAKE_INSTALL_PREFIX=$PREFIX

ninja install