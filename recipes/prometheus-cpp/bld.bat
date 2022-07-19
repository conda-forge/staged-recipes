@echo on

mkdir build-cpp
if errorlevel 1 exit 1

cd build-cpp
cmake .. ^
    -GNinja ^
    -DCMAKE_BUILD_TYPE=Release ^
    -DCMAKE_PREFIX_PATH=%CONDA_PREFIX% ^
    -DCMAKE_INSTALL_PREFIX=%LIBRARY_PREFIX% ^
    -DBUILD_SHARED_LIBS=ON ^
    -DENABLE_PUSH=ON ^
    -DENABLE_COMPRESSION=ON


cmake --build . --parallel 4
if errorlevel 1 exit 1

REM run tests
ctest -V

REM install the libraries and headers
cmake --install .
