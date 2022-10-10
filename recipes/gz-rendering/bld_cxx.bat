rmdir /s /q build
mkdir build
cd build

cmake ^
    -G "Ninja" ^
    -DCMAKE_INSTALL_PREFIX=%LIBRARY_PREFIX% ^
    -DCMAKE_BUILD_TYPE=Release ^
    -DCMAKE_INSTALL_SYSTEM_RUNTIME_LIBS_SKIP=True ^
    -DSKIP_optix:BOOL=ON ^
    %SRC_DIR%
if errorlevel 1 exit 1

:: Build.
cmake --build . --config Release
if errorlevel 1 exit 1

:: Install.
cmake --build . --config Release --target install
if errorlevel 1 exit 1

:: Test.
:: Do not run tests as they require to open a display and this is not supported on CI at the moment
:: See https://github.com/conda-forge/libignition-rendering4-feedstock/pull/19#issuecomment-937678806
:: set RENDER_ENGINE_VALUES=ogre
:: ctest --output-on-failure -C Release -E "INTEGRATION|PERFORMANCE|REGRESSION|UNIT_RenderingIface_TEST|check_"
:: if errorlevel 1 exit 1

setlocal EnableDelayedExpansion
:: Copy the [de]activate scripts to %PREFIX%\etc\conda\[de]activate.d.
:: This will allow them to be run on environment activation.
for %%F in (activate deactivate) DO (
    if not exist %PREFIX%\etc\conda\%%F.d mkdir %PREFIX%\etc\conda\%%F.d
    copy %RECIPE_DIR%\%%F.bat %PREFIX%\etc\conda\%%F.d\%PKG_NAME%_%%F.bat
    if %errorlevel% neq 0 exit /b %errorlevel%
)
