cmake -S . -B build -G Ninja -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX=$PREFIX -DTINYOPT_BUILD_TESTS=OFF -DTINYOPT_BUILD_DOCS=OFF
cmake --build build
cmake --install build