mkdir -p build
cd build
cmake .. -DCMAKE_BUILD_TYPE=Release -G"NMake Makefiles JOM" -DCMAKE_INSTALL_PREFIX=${PREFIX}
cmake --build . --verbose --config Release
cmake --install . --verbose