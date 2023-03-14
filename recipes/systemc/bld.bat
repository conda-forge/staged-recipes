setlocal EnableDelayedExpansion

mkdir build
if errorlevel 1 exit 1
cd build
if errorlevel 1 exit 1

cmake ^
    -G "NMake Makefiles" ^
    -DCMAKE_INSTALL_PREFIX:PATH=%LIBRARY_PREFIX% ^
    -DCMAKE_PREFIX_PATH:PATH=%LIBRARY_PREFIX% ^
    -DCMAKE_BUILD_TYPE=Release ^
    -DBUILD_SHARED_LIBS=ON ^
    %SRC_DIR%
if errorlevel 1 exit 1

nmake install
if errorlevel 1 exit 1
