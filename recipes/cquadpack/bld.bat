mkdir build
cd build
cmake .. -DCMAKE_PREFIX_PATH=%LIBRARY_PREFIX% -DCMAKE_BUILD_TYPE=Release -G "NMake Makefiles" -DCMAKE_INSTALL_PREFIX=%LIBRARY_PREFIX%
nmake
ctest -C Release --output-on-failure
nmake install
