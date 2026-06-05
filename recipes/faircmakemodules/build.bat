cmake -G Ninja -S %SRC_DIR% -B build -DCMAKE_INSTALL_PREFIX=%PREFIX%\Library
if errorlevel 1 exit 1
cmake --build build --parallel %CPU_COUNT% --target install
if errorlevel 1 exit 1
