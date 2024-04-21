@echo off
setlocal EnableDelayedExpansion

set "version=%PKG_VERSION%"
set "bin_dir=%PREFIX%\Scripts"
set "lein_file=%RECIPE_DIR%\scripts\lein.bat"

set "temp_file=lein_temp.bat"

for /f "delims=" %%i in (%lein_file%) do (
    set "line=%%i"
    if "!line:~0,13!"=="set LEIN_VERSION" (
        echo set LEIN_VERSION=%PKG_VERSION%>> "%temp_file%"
    ) else (
        echo %%i>> "%temp_file%"
    )
)

move /Y "%temp_file%" "%lein_file%"
if errorlevel 1 exit 1

mkdir %PREFIX%\Scripts

copy %RECIPE_DIR%\scripts\lein.bat %PREFIX%\Scripts\lein.bat > nul
if errorlevel 1 exit 1
echo copied :PREFIX:\Scripts\lein.bat

set ACTIVATE_DIR=%PREFIX%\etc\conda\activate.d
mkdir %ACTIVATE_DIR%

copy %RECIPE_DIR%\scripts\activate.bat %ACTIVATE_DIR%\lein-activate.bat > nul
if errorlevel 1 exit 1
echo copied :ACTIVATE_DIR:\lein-activate.bat
