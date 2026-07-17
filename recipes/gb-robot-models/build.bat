# CMAKE_ARGS env variable is not used as it is defined by
# compiler activation scripts
cmake -G Ninja -S %SRC_DIR% -B build -DCMAKE_INSTALL_PREFIX=%LIBRARY_PREFIX%
if errorlevel 1 exit 1
cmake --build build --parallel %CPU_COUNT% --target install
if errorlevel 1 exit 1
