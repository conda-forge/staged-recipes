mkdir build
cd build

cmake ^
    -G "NMake Makefiles" ^
    -DCMAKE_PREFIX_PATH=%LIBRARY_PREFIX% ^
    -DCMAKE_INSTALL_PREFIX=%LIBRARY_PREFIX% ^
    -DCMAKE_BUILD_TYPE=Release ^
    -DBUILD_SHARED_LIBS=1 ^
    -DBUILD_STATIC_LIBS=0 ^
    -DEXAMPLES_ENABLE=1 ^
    -DEXAMPLES_INSTALL=0 ^
    -DOPENMP_ENABLE=1 ^
    -DLAPACK_ENABLE=0 ^
    ..

nmake
nmake install
