mkdir build
cd build

cmake ^
    -G "Ninja" ^
    -DCMAKE_INSTALL_PREFIX=%LIBRARY_PREFIX% ^
    -DCMAKE_BUILD_TYPE=Release ^
    -DBUILD_TESTING=ON ^
    %SRC_DIR%
if errorlevel 1 exit 1

:: Build.
cmake --build . --config Release
if errorlevel 1 exit 1

:: Install.
cmake --build . --config Release --target install
if errorlevel 1 exit 1

:: Test.
:: Some tests disabled for https://github.com/robotology/ycm/issues/382
ctest --output-on-failure -C Release -E "YCMBootstrap-not-use-system|YCMBootstrap-disable-find|RunCMake.IncludeUrl"
if errorlevel 1 exit 1
