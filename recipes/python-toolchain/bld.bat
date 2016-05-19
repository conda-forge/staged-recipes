:: Print all of the commands run.
echo on

:: This works for `setuptools`, but breaks `distutils`.
:: Will need to figure out a better long term strategy.
copy "%RECIPE_DIR%\distutils.cfg" "%STDLIB_DIR%\distutils\distutils.cfg"
if errorlevel 1 exit 1

:: Configure `pip`.
IF NOT EXIST "%LIBRARY_PREFIX%\etc" mkdir "%LIBRARY_PREFIX%\etc"
if errorlevel 1 exit 1
copy "%RECIPE_DIR%\pip.conf" "%LIBRARY_PREFIX%\etc\pip.conf"
if errorlevel 1 exit 1
