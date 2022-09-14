mkdir build
cd build

@REM Configure the build of reaktplot
cmake -GNinja ..                               ^
    -DCMAKE_BUILD_TYPE=Release                 ^
    -DCMAKE_INSTALL_PREFIX=%LIBRARY_PREFIX%    ^
    -DCMAKE_INCLUDE_PATH=%LIBRARY_INC%         ^
    -DREAKTPLOT_PYTHON_INSTALL_PREFIX=%PREFIX% ^
    -DPYTHON_EXECUTABLE=%PYTHON%

@REM Build and install reaktplot in %LIBRARY_PREFIX%
ninja install
