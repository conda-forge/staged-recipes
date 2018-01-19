
:: Create build directory
mkdir build
cd build
set BUILD_CONFIG=Release

:: CMake
cmake .. ^
  -DCMAKE_BUILD_TYPE=$BUILD_CONFIG ^
  -DCMAKE_PREFIX_PATH:PATH="${PREFIX}" ^
  -DCMAKE_INSTALL_PREFIX:PATH="${PREFIX}" ^
	-DCMAKE_INSTALL_RPATH:PATH="${PREFIX}/lib" ^
	-DENABLE_TESTING:BOOL=OFF ^
	-DBUILD_SHARED_LIBS:BOOL=ON
if errorlevel 1 exit 1

:: Make
make -j $CPU_COUNT
make install
if errorlevel 1 exit 1

