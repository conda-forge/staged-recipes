rmdir /Q /S build
mkdir build
cd build

cmake .. ^
    %CMAKE_ARGS% ^
	-GNinja ^
	-DCMAKE_INSTALL_PREFIX=%LIBRARY_PREFIX% ^
	-DCMAKE_PREFIX_PATH=%PREFIX% ^
	-DENABLE_TESTS=OFF ^
	-DENABLE_PYTHON=OFF

if errorlevel 1 exit 1

ninja
if errorlevel 1 exit 1

ninja install
if errorlevel 1 exit 1
