@echo off
setlocal enabledelayedexpansion

cmake %CMAKE_ARGS% ^
    -B build ^
    -S %SRC_DIR% ^
    -GNinja ^
    -DWERROR=OFF || goto :error
cmake --build -j %CPU_COUNT% build || goto :error
ctest -V --test-dir build || goto :error
cmake --install build || goto :error

goto :eof

:error
echo Failed with error #%errorlevel%.
exit 1
