@echo off
setlocal

:: ensure %PREFIX%\share exists (mkdir -p)
if not exist "%PREFIX%\share" mkdir "%PREFIX%\share"

:: remove existing "%PREFIX%\share\dcm4che" (rm -rf)
if exist "%PREFIX%\share\dcm4che" rmdir /S /Q "%PREFIX%\share\dcm4che"

:: Prefer robocopy (preserves attributes, like cp -a). If not available, fall back to xcopy.
where robocopy >nul 2>&1
if %ERRORLEVEL% EQU 0 (
    if exist "%SRC_DIR%\bin"   robocopy "%SRC_DIR%\bin"   "%PREFIX%\share\dcm4che\bin"  /E /COPYALL /R:0 /W:0
    if exist "%SRC_DIR%\etc"   robocopy "%SRC_DIR%\etc"   "%PREFIX%\share\dcm4che\etc"  /E /COPYALL /R:0 /W:0
    if exist "%SRC_DIR%\js"    robocopy "%SRC_DIR%\js"    "%PREFIX%\share\dcm4che\js"   /E /COPYALL /R:0 /W:0
    if exist "%SRC_DIR%\lib"   robocopy "%SRC_DIR%\lib"   "%PREFIX%\share\dcm4che\lib"  /E /COPYALL /R:0 /W:0
) else (
    if exist "%SRC_DIR%\bin"   xcopy "%SRC_DIR%\bin\*"   "%PREFIX%\share\dcm4che\bin\"  /E /I /Y
    if exist "%SRC_DIR%\etc"   xcopy "%SRC_DIR%\etc\*"   "%PREFIX%\share\dcm4che\etc\"  /E /I /Y
    if exist "%SRC_DIR%\js"    xcopy "%SRC_DIR%\js\*"    "%PREFIX%\share\dcm4che\js\"   /E /I /Y
    if exist "%SRC_DIR%\lib"   xcopy "%SRC_DIR%\lib\*"   "%PREFIX%\share\dcm4che\lib\"  /E /I /Y
)

:: copy LICENSE.txt and README.md
if exist "%SRC_DIR%\LICENSE.txt" copy /Y "%SRC_DIR%\LICENSE.txt" "%PREFIX%\share\dcm4che\"
if exist "%SRC_DIR%\README.md"   copy /Y "%SRC_DIR%\README.md"   "%PREFIX%\share\dcm4che\"

endlocal

setlocal EnableDelayedExpansion

:: Copy the [de]activate scripts to %PREFIX%\etc\conda\[de]activate.d.
:: This will allow them to be run on environment activation.
for %%F in (activate deactivate) DO (
    if not exist %PREFIX%\etc\conda\%%F.d mkdir %PREFIX%\etc\conda\%%F.d
    copy %RECIPE_DIR%\%%F.bat %PREFIX%\etc\conda\%%F.d\%PKG_NAME%_%%F.bat
    :: Copy unix shell activation scripts, needed by Windows Bash users
    copy %RECIPE_DIR%\%%F.sh %PREFIX%\etc\conda\%%F.d\%PKG_NAME%_%%F.sh
)
