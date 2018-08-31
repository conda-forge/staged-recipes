:: use local build folder
mkdir build
cd build

:: configure
cmake .. ^
	-G "%CMAKE_GENERATOR%" ^
	-Wno-dev ^
	-DCMAKE_INSTALL_PREFIX:PATH="%LIBRARY_PREFIX%" ^
	-DCMAKE_BUILD_TYPE:STRING=Release ^
	-DCMAKE_EXPORT_COMPILE_COMMANDS=1
if errorlevel 1 exit 1

:: build
cmake --build . --config Release
if errorlevel 1 exit 1

:: test
ctest -V --build-config Release
if errorlevel 1 exit 1

:: install
cmake --build . --config Release --target install
if errorlevel 1 exit 1
