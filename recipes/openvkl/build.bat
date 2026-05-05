@echo on
setlocal enabledelayedexpansion

cmake -S . -B build -G "NMake Makefiles JOM" ^
    %CMAKE_ARGS% ^
    -DBUILD_SHARED_LIBS=ON ^
    -DBUILD_EXAMPLES=OFF ^
    -DBUILD_TESTING=ON ^
    -DBUILD_BENCHMARKS=OFF ^
    -DOpenVDB_ROOT="%LIBRARY_PREFIX%" ^
    -DISPC_EXECUTABLE="%BUILD_PREFIX%\bin\ispc.exe"
if errorlevel 1 exit 1

cmake --build build --parallel %CPU_COUNT%
if errorlevel 1 exit 1

ctest -V --test-dir build --parallel %CPU_COUNT%
if errorlevel 1 exit 1

cmake --install build
if errorlevel 1 exit 1
