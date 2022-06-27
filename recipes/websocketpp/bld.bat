mkdir build
cd build

cmake .. %CMAKE_ARGS% \
	-GNinja \
	-DCMAKE_INSTALL_PREFIX=%LIBRARY_PREFIX%

ninja install