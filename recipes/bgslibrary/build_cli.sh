cmake CMakeLists.txt -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX=$PREFIX 
cmake --build . --config Release --parallel ${CPU_COUNT}
make install