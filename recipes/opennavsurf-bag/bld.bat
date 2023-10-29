setlocal EnableDelayedExpansion

mkdir build
if errorlevel 1 exit 1

REM Configure CMake build
cmake -G Ninja ^
	-DCMAKE_BUILD_TYPE=Release ^
	-B build -S "%SRC_DIR%" ^
	-DCMAKE_PREFIX_PATH="%LIBRARY_PREFIX%" ^
    -DCMAKE_INSTALL_PREFIX="%LIBRARY_PREFIX%" ^
	-DCMAKE_INSTALL_LIBDIR=lib ^
    -DBUILD_SHARED_LIBS=ON ^
	-DBAG_CI:BOOL=ON ^
	-DBAG_BUILD_TESTS:BOOL=OFF ^
	-DBAG_BUILD_PYTHON:BOOL=OFF ^
	-DCMAKE_OBJECT_PATH_MAX=1024
	
if errorlevel 1 exit /b 1

REM Build C++
cmake --build build -j %CPU_COUNT% --config Release
if errorlevel 1 exit /b 1
