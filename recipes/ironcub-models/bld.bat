cmake -B build -S . ^
    -G "Ninja" ^
    -DCMAKE_BUILD_TYPE=Release ^
    -DCMAKE_INSTALL_PREFIX=%LIBRARY_PREFIX% ^
    -DCMAKE_PREFIX_PATH=%LIBRARY_PREFIX% ^
    %CMAKE_ARGS%
if errorlevel 1 exit 1

:: Build.
cmake --build build --config Release -j%CPU_COUNT%
if errorlevel 1 exit 1

:: Test.
:: ctest --test-dir build --output-on-failure --repeat until-pass:5 -C Release 
:: if errorlevel 1 exit 1

:: Install.
cmake --build build --config Release --target install
if errorlevel 1 exit 1

setlocal EnableDelayedExpansion
:: Generate and copy the [de]activate scripts to %PREFIX%\etc\conda\[de]activate.d.
:: This will allow them to be run on environment activation.
for %%F in (activate deactivate) DO (
    multisheller %RECIPE_DIR%\%%F.msh --output .\%%F

    if not exist %PREFIX%\etc\conda\%%F.d mkdir %PREFIX%\etc\conda\%%F.d
    copy %%F.bat %PREFIX%\etc\conda\%%F.d\%PKG_NAME%_%%F.bat
    if %errorlevel% neq 0 exit /b %errorlevel%

    copy %%F.sh %PREFIX%\etc\conda\%%F.d\%PKG_NAME%_%%F.sh
    if %errorlevel% neq 0 exit /b %errorlevel%

    copy %%F.bash %PREFIX%\etc\conda\%%F.d\%PKG_NAME%_%%F.bash
    if %errorlevel% neq 0 exit /b %errorlevel%

    copy %%F.ps1 %PREFIX%\etc\conda\%%F.d\%PKG_NAME%_%%F.ps1
    if %errorlevel% neq 0 exit /b %errorlevel%

    copy %%F.xsh %PREFIX%\etc\conda\%%F.d\%PKG_NAME%_%%F.xsh
    if %errorlevel% neq 0 exit /b %errorlevel%

    copy %%F.zsh %PREFIX%\etc\conda\%%F.d\%PKG_NAME%_%%F.zsh
    if %errorlevel% neq 0 exit /b %errorlevel%
)
