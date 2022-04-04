@echo on

mkdir build
cd build

:: eigen3 is expected in this subdir; otherwise a bundled one is extracted
mkdir third-party || goto :error
mklink /D third-party\eigen3 %LIBRARY_INC%\eigen3 || goto :error

cmake %SRC_DIR% ^
    -G "NMake Makefiles JOM" ^
    -DCMAKE_BUILD_TYPE=Release ^
    -DCMAKE_INSTALL_PREFIX="%LIBRARY_PREFIX%" ^
    -DCMAKE_PREFIX_PATH="%LIBRARY_PREFIX%" ^
    || goto :error

jom -j %NUMBER_OF_PROCESSORS% || goto :error
jom -j %NUMBER_OF_PROCESSORS% install || goto :error

goto :EOF

:error
echo Failed with error #%errorlevel%.
exit /b %errorlevel%
