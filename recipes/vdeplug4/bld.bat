@echo on
setlocal EnableDelayedExpansion

mkdir build || exit 1
cd build || exit 1


cmake "%CMAKE_ARGS%" .. || exit 1
cmake  --build . -j %CPU_COUNT% || exit 1

ctest -N
ctest -j %CPU_COUNT%

REM put the error check back in place for after ctest before merging
::if errorlevel 1 exit 1

::cmake --build . --target install || exit 1
