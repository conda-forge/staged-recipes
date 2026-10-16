@echo off

cmake -S . -B build %CMAKE_ARGS% ^
	-DCMAKE_BUILD_TYPE=Release ^
	"-DCMAKE_C_FLAGS_RELEASE=/O2 /Ob2" ^
	"-DCMAKE_INSTALL_PREFIX=%LIBRARY_PREFIX%" ^
	-DBUILD_SHARED_LIBS=ON ^
	-DBUILD_TESTING=ON
if errorlevel 1 exit /b 1

cmake --build build --config Release --parallel %CPU_COUNT%
if errorlevel 1 exit /b 1

cmake --install build --config Release
if errorlevel 1 exit /b 1
