cmake -DCMAKE_INSTALL_PREFIX=%PREFIX% -G Ninja -B _build

cmake --install _build
