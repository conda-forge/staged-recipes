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

:: Copy the [de]activate scripts to %PREFIX%\etc\conda\[de]activate.d.
:: This will allow them to be run on environment activation.
FOR %%F IN (activate deactivate) DO (
    IF NOT EXIST "%PREFIX%\etc\conda\%%F.d" MKDIR "%PREFIX%\etc\conda\%%F.d"
    if errorlevel 1 exit 1
    COPY "%RECIPE_DIR%\%%F.bat" "%PREFIX%\etc\conda\%%F.d\python-toolchain_%%F.bat"
    if errorlevel 1 exit 1
)
