
cmake ^
    -S . ^
    -B build ^
    -G "Ninja" ^
    -DCMAKE_INSTALL_PREFIX=%LIBRARY_PREFIX% ^
    -DCMAKE_PREFIX_PATH=%LIBRARY_PREFIX% ^
    -DCMAKE_BUILD_TYPE=Release ^
    -DBUILD_TESTING:BOOL=ON ^
    %SRC_DIR%
if errorlevel 1 exit 1

:: Build.
cmake --build build --config Release
if errorlevel 1 exit 1

:: Test.
ctest --test-dir build --output-on-failure --repeat until-pass:5 -C Release
if errorlevel 1 exit 1

:: Install.
cmake --build build --config Release --target install
if errorlevel 1 exit 1

setlocal EnableDelayedExpansion
:: Generate and copy the [de]activate scripts to %PREFIX%\etc\conda\[de]activate.d.
:: This will allow them to be run on environment activation.
multisheller %RECIPE_DIR%\activate.msh --output .\activate

if not exist %PREFIX%\etc\conda\activate.d mkdir %PREFIX%\etc\conda\activate.d
copy activate.bat %PREFIX%\etc\conda\activate.d\iit-r1-models_activate.bat
if %errorlevel% neq 0 exit /b %errorlevel%

multisheller %RECIPE_DIR%\deactivate.msh --output .\deactivate

if not exist %PREFIX%\etc\conda\deactivate.d mkdir %PREFIX%\etc\conda\deactivate.d
copy deactivate.bat %PREFIX%\etc\conda\deactivate.d\iit-r1-models_deactivate.bat
if %errorlevel% neq 0 exit /b %errorlevel%
