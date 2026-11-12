cmake -S . -B build-docs -G Ninja -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX=$PREFIX -DTINYOPT_BUILD_TESTS=OFF -DTINYOPT_BUILD_DOCS=ON -DTINYOPT_BUILD_PACKAGES=OFF -DTINYOPT_BUILD_PIP_PACKAGE=OFF
cmake --build build-docs --target docs
cmake --build build-docs
cmake --install build-docs