cd build/cmake
cmake ../.. -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX=%PREFIX%

cmake --build . --config Release
cmake --build . --config Release --target INSTALL
