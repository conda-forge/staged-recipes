@echo on

mkdir build && cd build

cmake %CMAKE_ARGS% ^
    -GNinja ^
    -DCMAKE_BUILD_TYPE=Release ^
    -DCMAKE_INSTALL_PREFIX="%LIBRARY_PREFIX%" ^
    -DBUILD_EXAMPLES=OFF ^
    -DBUILD_FAKENECT=ON ^
    -DBUILD_C_SYNC=ON ^
    -DBUILD_CPP=ON ^
    -DBUILD_CV=OFF ^
    -DBUILD_PYTHON=OFF ^
    -DBUILD_PYTHON2=OFF ^
    -DBUILD_PYTHON3=OFF ^
    -DBUILD_REDIST_PACKAGE=ON ^
    ..
if errorlevel 1 exit /b 1

ninja -j%CPU_COUNT%
if errorlevel 1 exit /b 1

ninja install
if errorlevel 1 exit /b 1