mkdir build
mkdir build\corelib
mkdir build\wrapper

cd build\corelib
cmake ^
    -G "NMake Makefiles JOM" ^
    -D ANACONDA_BUILD=ON ^
    -D ANACONDA_BASE=%LIBRARY_PREFIX% ^
    -D BUILD_NCORES=%NUMBER_OF_PROCESSORS% ^
    ..\..\corelib
if errorlevel 1 exit 1

cmake --build . --target install
if errorlevel 1 exit 1

cd ..\wrapper
cmake ^
    -G "NMake Makefiles JOM" ^
    -D ANACONDA_BUILD=ON ^
    -D ANACONDA_BASE=%LIBRARY_PREFIX% ^
    -D BUILD_NCORES=%NUMBER_OF_PROCESSORS% ^
    ..\..\wrapper
if errorlevel 1 exit 1

cmake --build . --target install
if errorlevel 1 exit 1
