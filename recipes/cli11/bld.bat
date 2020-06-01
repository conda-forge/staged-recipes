mkdir build
cd build

cmake ^
	-G "NMake Makefiles" ^
	-DCLI11_BUILD_TESTS=OFF ^
	-DCMAKE_INSTALL_PREFIX=%LIBRARY_PREFIX% ^
	-DCLI11_BUILD_EXAMPLES=OFF ^
	%SRC_DIR%

nmake install