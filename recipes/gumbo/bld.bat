mkdir build
cd build
cmake .. ^
	-GNinja ^
	-DCMAKE_INSTALL_PREFIX=%LIBRARY_PREFIX% ^
	-DCMAKE_BUILD_TYPE=Release ^
	-DBUILD_SHARED_LIBS=ON ^
	-DCMAKE_WINDOWS_EXPORT_ALL_SYMBOLS=ON

ninja
ninja install