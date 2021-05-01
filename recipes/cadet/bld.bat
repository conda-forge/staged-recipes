mkdir build && cd build
cmake ^
    -G "NMake Makefiles" ^
    -DCMAKE_PREFIX_PATH=$PREFIX ^
    -DCMAKE_INSTALL_PREFIX=$PREFIX ^
    -DENABLE_CADET_MEX=OFF ^
    -DBLA_VENDOR=Intel10_64lp ^
    .. 

nmake
nmake install
