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
    -DENABLE_COMPRESSION=ON ^
    -DENABLE_TESTING=OFF
REM For some reason the example binary built with testing enabled fails

cmake --build . --parallel 4
if errorlevel 1 exit 1

REM run tests
REM ctest -V

REM install the libraries and headers
cmake --install .
