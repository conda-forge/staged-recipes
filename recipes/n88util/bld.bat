
:: Create build directory
mkdir build
cd build
set BUILD_CONFIG=Release

:: CMake
cmake .. ^
  -DCMAKE_BUILD_TYPE=%BUILD_CONFIG% ^
  -DCMAKE_INSTALL_PREFIX:PATH="%LIBRARY_PREFIX%" ^
	-DENABLE_TESTING:BOOL=OFF ^
	-DBUILD_SHARED_LIBS:BOOL=ON
if errorlevel 1 exit 1

:: Make
make -j %NUMBER_OF_PROCESSORS%
make install
if errorlevel 1 exit 1
