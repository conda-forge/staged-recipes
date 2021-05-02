mkdir build
cd build

cmake ^
    -G "NMake Makefiles" ^
    -DCMAKE_PREFIX_PATH=%PREFIX% ^
    -DCMAKE_INSTALL_PREFIX=%PREFIX% ^
    -DCMAKE_BUILD_TYPE=Release ^
    -DBUILD_SHARED_LIBS=OFF ^
    -DENABLE_STATIC_LINK_DEPS=ON
    -DENABLE_CADET_MEX=OFF ^
    -DBLA_VENDOR=Intel10_64lp ^
    ..

nmake
nmake install

