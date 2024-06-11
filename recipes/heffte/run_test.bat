@echo on

set "OMP_NUM_THREADS=2"

cmake   ^
    -S %PREFIX%\share\heffte\testing  ^
    -B build_test                     ^
    -DBUILD_SHARED_LIBS=ON            ^
    -DCMAKE_VERBOSE_MAKEFILE=ON
if errorlevel 1 exit 1

cmake --build build_test
if errorlevel 1 exit 1

cmake --build build_test --target test
if errorlevel 1 exit 1
