mkdir build
cd build

cmake -LAH -G Ninja                                                       ^
    -DCMAKE_BUILD_TYPE="Release"                                          ^
    -DCMAKE_CXX_FLAGS="/DGSL_DLL /DWIN32"                                 ^
    -DCMAKE_PREFIX_PATH=%LIBRARY_PREFIX%                                  ^
    -DCMAKE_INSTALL_PREFIX=%LIBRARY_PREFIX%                               ^
    ..

ninja install
