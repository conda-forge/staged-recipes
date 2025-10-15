@echo off
setlocal

if not defined PREFIX (
  echo PREFIX not set
  exit /b 1
)

if not exist "%PREFIX%\share" mkdir "%PREFIX%\share"
if exist "%PREFIX%\share\dcm4che" rmdir /S /Q "%PREFIX%\share\dcm4che"
if not exist "%PREFIX%\share\dcm4che" mkdir "%PREFIX%\share\dcm4che"


move "%SRC_DIR%\bin" "%PREFIX%\share\dcm4che"
move "%SRC_DIR%\etc" "%PREFIX%\share\dcm4che"
move "%SRC_DIR%\js" "%PREFIX%\share\dcm4che"
move "%SRC_DIR%\lib" "%PREFIX%\share\dcm4che"
move "%SRC_DIR%\LICENSE.txt" "%PREFIX%\share\dcm4che"
move "%SRC_DIR%\README.md" "%PREFIX%\share\dcm4che"

setlocal EnableDelayedExpansion

:: Copy the [de]activate scripts to %PREFIX%\etc\conda\[de]activate.d.
:: This will allow them to be run on environment activation.
for %%F in (activate deactivate) DO (
    if not exist %PREFIX%\etc\conda\%%F.d mkdir %PREFIX%\etc\conda\%%F.d
    copy %RECIPE_DIR%\%%F.bat %PREFIX%\etc\conda\%%F.d\%PKG_NAME%_%%F.bat
    :: Copy unix shell activation scripts, needed by Windows Bash users
    copy %RECIPE_DIR%\%%F.sh %PREFIX%\etc\conda\%%F.d\%PKG_NAME%_%%F.sh
)
