cmake -DCMAKE_INSTALL_PREFIX=%PREFIX% -DELFIO_BUILD_TESTS=on -G Ninja -B _build

cmake --build _build

cd _build
ctest

cd ..


cmake --install _build
