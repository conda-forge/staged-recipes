mkdir build
mkdir build\corelib
mkdir build\wrapper

cd build\corelib
cmake ^
    -G "NMake Makefiles JOM" ^
    -D ANACONDA_BUILD=ON ^
    -D ANACONDA_BASE=%PREFIX% ^
    -D BUILD_NCORES=%CPU_COUNT% ^
    ..\..\corelib
if errorlevel 1 exit 1

cmake --build . --target install
if errorlevel 1 exit 1

cd ..\wrapper
cmake ^
    -G "NMake Makefiles JOM" ^
    -D ANACONDA_BUILD=ON ^
    -D ANACONDA_BASE=%PREFIX% ^
    -D BUILD_NCORES=%CPU_COUNT% ^
    ..\..\wrapper
if errorlevel 1 exit 1

cmake --build . --target install
if errorlevel 1 exit 1
