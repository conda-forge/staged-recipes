cmake -S "%SRC_DIR%" -B build

if errorlevel 1 exit 1

set CONDA_PREFIX=%PREFIX%

if errorlevel 1 exit 1

cmake --build build -- -j%CPU_COUNT%

if errorlevel 1 exit 1

cmake --install build --prefix %SP_DIR%
