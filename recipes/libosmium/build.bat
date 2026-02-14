@echo off
setlocal enabledelayedexpansion

cmake %CMAKE_ARGS% ^
    -B build ^
    -S %SRC_DIR% ^
    -GNinja ^
    -DCMAKE_POLICY_VERSION_MINIMUM=3.5 ^
    -DWERROR=OFF || goto :error
cmake --build build -j %CPU_COUNT%  || goto :error
ctest -V --test-dir build || goto :error
cmake --install build || goto :error

goto :eof

:error
echo Failed with error #%errorlevel%.
exit 1
