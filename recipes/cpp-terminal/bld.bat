mkdir build
cd build

cmake .. ^
    %CMAKE_ARGS%  ^
    -D CMAKE_INSTALL_PREFIX=%LIBRARY_PREFIX% ^
    -G "NMake Makefiles"

nmake install