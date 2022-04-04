@echo on

mkdir build
cd build

:: create this directory so CMake doesn't use the bundled eigen
mkdir %SRC_DIR%\third-party\eigen3

cmake %SRC_DIR% ^
    %CMAKE_ARGS% ^
    -DCMAKE_BUILD_TYPE=Release ^
    -DCMAKE_INSTALL_LIBDIR=%PREFIX%\lib

make
make install

goto :EOF

:error
echo Failed with error #%errorlevel%.
exit /b %errorlevel%