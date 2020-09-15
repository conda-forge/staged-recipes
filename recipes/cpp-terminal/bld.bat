mkdir build
cd build
if errorlevel neq 0 exit 1

cmake .. ^
    %CMAKE_ARGS%  ^
    -D CMAKE_INSTALL_PREFIX=%LIBRARY_PREFIX% ^
    -G "NMake Makefiles"

if errorlevel neq 0 exit 1

nmake install
