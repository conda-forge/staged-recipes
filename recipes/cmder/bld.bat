xcopy cmder %PREFIX%\cmder /e /i /y /s
if errorlevel 1 exit 1

IF NOT EXIST %PREFIX%\Menu mkdir %PREFIX%\Menu
if errorlevel 1 exit 1

copy %RECIPE_DIR%\menu-windows.json %PREFIX%\Menu\
if errorlevel 1 exit 1

exit 0
