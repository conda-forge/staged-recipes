%PYTHON% -m pip install . -vv --no-deps --no-build-isolation
if %ERRORLEVEL% neq 0 exit 1

:: Install the menuinst shortcut spec and its icons into %PREFIX%\Menu so the
:: installer (conda / mamba / pixi global) creates a native desktop entry.
if not exist "%PREFIX%\Menu" mkdir "%PREFIX%\Menu"
copy /Y "%RECIPE_DIR%\menu\croppy.json" "%PREFIX%\Menu\croppy.json"
if %ERRORLEVEL% neq 0 exit 1
copy /Y "%RECIPE_DIR%\icons\croppy.ico" "%PREFIX%\Menu\croppy.ico"
if %ERRORLEVEL% neq 0 exit 1
copy /Y "%RECIPE_DIR%\icons\croppy.icns" "%PREFIX%\Menu\croppy.icns"
if %ERRORLEVEL% neq 0 exit 1
copy /Y "%RECIPE_DIR%\icons\croppy.png" "%PREFIX%\Menu\croppy.png"
if %ERRORLEVEL% neq 0 exit 1
