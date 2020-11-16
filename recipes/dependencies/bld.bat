setlocal enableextensions
setlocal enabledelayedexpansion


xcopy %SRC_DIR%\dependencies %LIBRARY_PREFIX%\dependencies /E /I /Y
if errorlevel 1 exit 1

echo F | xcopy %RECIPE_DIR%\dependencies.cmd %LIBRARY_PREFIX%\bin\dependencies.cmd /Y
if errorlevel 1 exit 1
