cmake -DCMAKE_INSTALL_PREFIX=%PREFIX% -DELFIO_BUILD_TESTS=on -G Ninja -B _build

cmake --install _build
