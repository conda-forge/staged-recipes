mkdir build
cd build

cmake ^
    -DCMAKE_INSTALL_PREFIX=%PREFIX%" ^
    ..\src ^
    -DCMAKE_INSTALL_LIBDIR=lib ^
    -DCMAKE_BUILD_TYPE=Release ^
    -G “NMake Makefiles" ^
    %CMAKE_ARGS%

nmake
nmake test
nmake install

