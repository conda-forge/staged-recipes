mkdir build
cd build

cmake ^
    -G "NMake Makefiles" ^
    -DCMAKE_PREFIX_PATH=%LIBRARY_PREFIX% ^
    -DCMAKE_INSTALL_PREFIX=%LIBRARY_PREFIX% ^
    -DCMAKE_BUILD_TYPE=Release ^
    -DBUILD_SHARED_LIBS=0 ^
    -DBUILD_STATIC_LIBS=1 ^
    -DEXAMPLES_ENABLE=1 ^
    -DEXAMPLES_INSTALL=0 ^
    -DOPENMP_ENABLE=0 ^
    -DLAPACK_ENABLE=0 ^
    ..

nmake
nmake install
