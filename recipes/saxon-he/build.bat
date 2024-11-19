@echo off

set INSTALL_DIR=%LIBRARY_LIB%\SaxonHE
mkdir %INSTALL_DIR%

rem Install built files
move saxon-he-*.jar %INSTALL_DIR%
if errorlevel 1 exit 1

mkdir %INSTALL_DIR%\lib
move lib\* %INSTALL_DIR%\lib
if errorlevel 1 exit 1

mkdir %INSTALL_DIR%\doc
move doc\* %INSTALL_DIR%\doc
if errorlevel 1 exit 1

mkdir %INSTALL_DIR%\notices
move notices\* %INSTALL_DIR%\notices
if errorlevel 1 exit 1

:: Copy the [de]activate scripts to %PREFIX%\etc\conda\[de]activate.d.
:: This will allow them to be run on environment activation.
for %%F in (activate deactivate) do (
    if not exist %PREFIX%\etc\conda\%%F.d mkdir %PREFIX%\etc\conda\%%F.d
    if errorlevel 1 exit 1
    copy %RECIPE_DIR%\scripts\%%F.bat %PREFIX%\etc\conda\%%F.d\%PKG_NAME%_%%F.bat
)