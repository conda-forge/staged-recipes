set MENU_DIR=%PREFIX%\Menu
mkdir %MENU_DIR%

set SCRIPT_DIR=%PREFIX%\Scripts
mkdir %SCRIPT_DIR%

copy %RECIPE_DIR%\rodeo.ico %MENU_DIR%
if errorlevel 1 exit 1

copy %RECIPE_DIR%\menu-windows.json %MENU_DIR%\rodeo.json
if errorlevel 1 exit 1

%PYTHON% setup.py install --single-version-externally-managed --record record.txt
if errorlevel 1 exit 1

