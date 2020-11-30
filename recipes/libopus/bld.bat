mkdir build
cd build

cmake .. -G "Ninja" ^
	-D CMAKE_INSTALL_PREFIX=%LIBRARY_PREFIX% ^
	-D BUILD_SHARED_LIBS=ON ^
	%CMAKE_ARGS% ^
	%SRC_DIR%