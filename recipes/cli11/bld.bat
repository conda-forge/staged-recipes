mkdir build
cd build

cmake ^
	-G "NMake Makefiles" ^
	-DCMAKE_INSTALL_PREFIX=%LIBRARY_PREFIX% ^
	%SRC_DIR%

nmake install