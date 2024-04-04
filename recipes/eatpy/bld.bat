set FFLAGS=-fno-range-check
set CFLAGS=-DMS_WIN64
REM cd %SRC_DIR%
REM install.bat -DPython3_EXECUTABLE="%PYTHON%" -G "MinGW Makefiles" -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX="%PREFIX%" %CMAKE_ARGS%
cmake -S "%SRC_DIR%" -B build -DPython3_EXECUTABLE="%PYTHON%" -G "MinGW Makefiles" -DFABM_EXTRA_INSTITUTES=ogs -DFABM_OGS_BASE="%SRC_DIR%\extern\ogs" -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX="%PREFIX%" %CMAKE_ARGS%
if errorlevel 1 exit 1
cmake --build build --config Release --parallel %CPU_COUNT% --target install
if errorlevel 1 exit 1
rmdir /S /Q build
