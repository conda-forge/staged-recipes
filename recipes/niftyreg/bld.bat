@echo on

mkdir build
cd build

:: eigen3 is expected in this subdir; otherwise a bundled one is extracted
mkdir third-party
mklink /D %PREFIX%\include\eigen3 third-party\eigen3

cmake %SRC_DIR% ^
    %CMAKE_ARGS% ^
    -DCMAKE_BUILD_TYPE=Release ^
    -DCMAKE_INSTALL_LIBDIR=%LIBRARY_LIB%

make
make install

goto :EOF

:error
echo Failed with error #%errorlevel%.
exit /b %errorlevel%