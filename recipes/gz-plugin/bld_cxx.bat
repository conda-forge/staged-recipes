mkdir build
cd build

cmake ^
    -G "Ninja" ^
    -DCMAKE_INSTALL_PREFIX=%LIBRARY_PREFIX% ^
    -DCMAKE_BUILD_TYPE=Release ^
    -DCMAKE_INSTALL_SYSTEM_RUNTIME_LIBS_SKIP=True ^
    -DBUILD_TESTING=ON ^
    %SRC_DIR%
if errorlevel 1 exit 1

:: Build.
:: Workaround for https://github.com/conda-forge/staged-recipes/pull/20623#issuecomment-1268431348
cmake --build . --config Release --target GzDummyStaticPlugin
if errorlevel 1 exit 1

cmake --build . --config Release
if errorlevel 1 exit 1

:: Install.
cmake --build . --config Release --target install
if errorlevel 1 exit 1

:: Test.
ctest --output-on-failure -C Release
if errorlevel 1 exit 1
