@echo on

mkdir build
cd build

:: eigen3 is expected in this subdir; otherwise a bundled one is extracted
mkdir third-party || goto :error
mklink /D %LIBRARY_INC%\eigen3 third-party\eigen3 || goto :error

cmake %SRC_DIR% ^
    %CMAKE_ARGS% ^
    -G "NMake Makefiles JOM" ^
    -DCMAKE_BUILD_TYPE=Release ^
    -DCMAKE_INSTALL_LIBDIR=%LIBRARY_LIB% || goto :error

jom -j %NUMBER_OF_PROCESSORS% || goto :error
jom -j %NUMBER_OF_PROCESSORS% install || goto :error

goto :EOF

:error
echo Failed with error #%errorlevel%.
exit /b %errorlevel%