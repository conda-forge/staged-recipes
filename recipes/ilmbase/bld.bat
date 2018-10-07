cmake -DCMAKE_INSTALL_PREFIX=%PREFIX% -G "Ninja" -DCMAKE_PREFIX_PATH=%PREFIX%

ninja
ninja install
