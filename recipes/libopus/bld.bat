mkdir build
cd build
if errorlevel 1 exit /b 1

cmake -G "Ninja" ^
	-DCMAKE_INSTALL_PREFIX=%LIBRARY_PREFIX% ^
	-DBUILD_SHARED_LIBS=ON ^
	-DCMAKE_BUILD_TYPE=Release ^
	%CMAKE_ARGS% ^
	%SRC_DIR%

if errorlevel 1 exit /b 1

ninja install
if errorlevel 1 exit /b 1