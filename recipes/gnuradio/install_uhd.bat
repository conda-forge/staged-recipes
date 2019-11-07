setlocal EnableDelayedExpansion

cd build
cmake -P gr-uhd/cmake_install.cmake
if errorlevel 1 exit 1
