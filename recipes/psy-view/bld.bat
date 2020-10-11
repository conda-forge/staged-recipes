%PYTHON% -m pip install . --no-deps --ignore-installed -vvv
if errorlevel 1 exit 1

set MENU_DIR=%PREFIX%\Menu
IF NOT EXIST (%MENU_DIR%) mkdir %MENU_DIR%

copy %RECIPE_DIR%\psyplot.ico %MENU_DIR%\psyplot.ico
if errorlevel 1 exit 1

copy %RECIPE_DIR%\menu-windows.json %MENU_DIR%\psy-view_shortcut.json
if errorlevel 1 exit 1
