set CONDA_PREFIX=%PREFIX%
if errorlevel 1 exit 1

cmake -B build -S "%SRC_DIR%" ^
	-G Ninja ^
    -DCMAKE_BUILD_TYPE=Release
if errorlevel 1 exit 1

cmake --build build -j ${CPU_COUNT}
if errorlevel 1 exit 1

if not exist %SP_DIR% mkdir %SP_DIR%
if errorlevel 1 exit 1

copy build/OCP.cp*-*.* %SP_DIR%
if errorlevel 1 exit 1