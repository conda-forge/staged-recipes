echo TBB_CXX_TYPE=gcc >> make\local
if errorlevel 1 exit 1
:: echo TBB_INTERFACE_NEW=true >> make\local
if errorlevel 1 exit 1
echo TBB_INC=$(PREFIX)\Library\include >> make\local
if errorlevel 1 exit 1
echo TBB_LIB=$(PREFIX)\Library\lib >> make\local
type make\local
if errorlevel 1 exit 1
mingw32-make clean-all
if errorlevel 1 exit 1
mingw32-make build -j%CPU_COUNT%
if errorlevel 1 exit 1

Xcopy /s /e . %PREFIX%\bin\cmdstan
if errorlevel 1 exit 1

:: activate/deactivate setup
setlocal EnableDelayedExpansion

:: Copy the [de]activate scripts to %PREFIX%\etc\conda\[de]activate.d.
:: This will allow them to be run on environment activation.
for %%F in (activate deactivate) DO (
    if not exist %PREFIX%\etc\conda\%%F.d mkdir %PREFIX%\etc\conda\%%F.d
    copy %RECIPE_DIR%\%%F.bat %PREFIX%\etc\conda\%%F.d\%PKG_NAME%_%%F.bat
    :: Copy unix shell activation scripts, needed by Windows Bash users
    if exists %RECIPE_DIR%\%%F.sh copy %RECIPE_DIR%\%%F.sh %PREFIX%\etc\conda\%%F.d\%PKG_NAME%_%%F.sh
)
