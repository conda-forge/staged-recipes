echo d | Xcopy /s /e /y . %PREFIX%\bin\cmdstan > NUL
if errorlevel 1 exit 1

cd %PREFIX%\bin\cmdstan

echo TBB_CXX_TYPE=gcc >> make\local
if errorlevel 1 exit 1
type make\local
if errorlevel 1 exit 1

mingw32-make clean-all
if errorlevel 1 exit 1

mingw32-make build -j%CPU_COUNT%
if errorlevel 1 exit 1

:: activate/deactivate setup
echo CMDSTAN=%PREFIX%\bin\cmdstan > %RECIPE_DIR%\activate.bat
:: setlocal EnableDelayedExpansion
:: Copy the [de]activate scripts to %PREFIX%\etc\conda\[de]activate.d.
:: This will allow them to be run on environment activation.
::for %%F in (activate deactivate) DO (
::    if not exist %PREFIX%\etc\conda\%%F.d mkdir %PREFIX%\etc\conda\%%F.d
::    copy %RECIPE_DIR%\%%F.bat %PREFIX%\etc\conda\%%F.d\%PKG_NAME%_%%F.bat
    :: Copy unix shell activation scripts, needed by Windows Bash users
    ::if exists %RECIPE_DIR%\%%F.sh copy %RECIPE_DIR%\%%F.sh %PREFIX%\etc\conda\%%F.d\%PKG_NAME%_%%F.sh
::)
