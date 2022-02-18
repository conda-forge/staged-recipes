set CONDA_PREFIX=%PREFIX%
if errorlevel 1 exit 1

cmake -B build -S "%SRC_DIR%" ^
	-G Ninja ^
    -DCMAKE_BUILD_TYPE=Release ^
    -DPython3_FIND_STRATEGY=LOCATION ^
    -DPython3_ROOT_DIR=%CONDA_PREFIX% ^
    -DCMAKE_MODULE_LINKER_FLAGS="/FORCE:MULTIPLE"
if errorlevel 1 exit 1

cmake --build build -j %CPU_COUNT% -- -v -k 0
if errorlevel 1 exit 1

if not exist "%SP_DIR%" mkdir "%SP_DIR%"
if errorlevel 1 exit 1

copy build/OCP.cp*-*.* "%SP_DIR%"
if errorlevel 1 exit 1