mkdir -p build
cd build
cmake .. -DCMAKE_BUILD_TYPE=Release -G"NMake Makefiles" -DCMAKE_INSTALL_PREFIX=${PREFIX}
nmake