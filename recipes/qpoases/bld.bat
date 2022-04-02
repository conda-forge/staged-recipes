mkdir build
cd build

:: Compilation of Windows shared library is not supported (see https://github.com/coin-or/qpOASES/pull/109)
cmake ^
    -G "Ninja" ^
    -DCMAKE_INSTALL_PREFIX=%LIBRARY_PREFIX% ^
    -DCMAKE_BUILD_TYPE=Release ^
    -DQPOASES_AVOID_LA_NAMING_CONFLICTS:BOOL=ON ^
    -DBUILD_SHARED_LIBS:BOOL=OFF ^
    -DBUILD_TESTING:BOOL=ON ^
    %SRC_DIR%
if errorlevel 1 exit 1

:: Build.
cmake --build . --config Release
if errorlevel 1 exit 1

:: Install.
cmake --build . --config Release --target install
if errorlevel 1 exit 1

:: Test.
ctest --output-on-failure -C Release
if errorlevel 1 exit 1
