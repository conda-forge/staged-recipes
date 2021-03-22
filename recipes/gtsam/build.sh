mkdir build
cd build

cmake .. ${CMAKE_ARGS} \
	-GNinja \
	-DGTSAM_BUILD_WITH_MARCH_NATIVE=OFF \
	-DGTSAM_USE_SYSTEM_EIGEN=ON \
	-DGTSAM_INSTALL_CPPUNITLITE=OFF

ninja install

ninja check