cmake -G "Ninja Multi-Config" -B build --preset conda_raspa3 -DCMAKE_INSTALL_PREFIX=%PREFIX%
if errorlevel 1 exit 1
ninja -C build install
if errorlevel 1 exit 1
