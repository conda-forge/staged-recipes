cmake -S$SRC_DIR -Bbuild -GNinja -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX=$PREFIX -Drxshared=1
cmake --build build
cmake --build build -- test
cmake --build build -- install
