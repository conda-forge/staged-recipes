mkdir build
cd build

cmake ^
    -G "NMake Makefiles" ^
    -DCMAKE_PREFIX_PATH=%PREFIX% ^
    -DCMAKE_INSTALL_PREFIX=%PREFIX% ^
    -DCMAKE_BUILD_TYPE=Release ^
    -DENABLE_CADET_MEX=OFF ^
    -DBLA_VENDOR=Intel10_64lp_seq ^
    ..

nmake
nmake install

