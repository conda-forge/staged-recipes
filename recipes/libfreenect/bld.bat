mkdir build
cd build

cmake .. -DCMAKE_INSTALL_PREFIX=%LIBRARY_PREFIX% -G "Ninja"

ninja -j${CPU_COUNT}
ninja install