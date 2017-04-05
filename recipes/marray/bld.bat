mkdir build
cd build

cmake ^
    -G "%CMAKE_GENERATOR%" ^
    -DCMAKE_PREFIX_PATH=%LIBRARY_PREFIX% ^
    -DCMAKE_INSTALL_PREFIX=%LIBRARY_PREFIX% ^
    -DHDF5_C_LIBRARIES=%LIBRARY_PREFIX%\Library\lib\hdf5.lib ^
    -DWITH_CPP11=yes ^
    ..

cmake --build . --config Release
cmake --build . --config Release --target install

ctest
