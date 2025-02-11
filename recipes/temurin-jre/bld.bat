@echo off
setlocal enabledelayedexpansion

:: Create activate/deactivate directories
for %%C in (activate deactivate) do (
    if not exist "%PREFIX%\etc\conda\%%C.d" mkdir "%PREFIX%\etc\conda\%%C.d"
    copy "%RECIPE_DIR%\scripts\%%C.bat" "%PREFIX%\etc\conda\%%C.d\%PKG_NAME%_%%C.bat"
)

:: Create temurin directory and move files
if not exist "%PREFIX%\opt" mkdir "%PREFIX%\opt"
if not exist "%PREFIX%\opt\temurin" mkdir "%PREFIX%\opt\temurin"
move bin "%PREFIX%\opt\temurin\"
move conf "%PREFIX%\opt\temurin\"
move legal "%PREFIX%\opt\temurin\"
move lib "%PREFIX%\opt\temurin\"
move NOTICE "%PREFIX%\opt\temurin\"
move release "%PREFIX%\opt\temurin\"

:: Create bin directory if it doesn't exist
if not exist "%PREFIX%\bin" mkdir "%PREFIX%\bin"

:: Create symlink to java.exe
mklink "%PREFIX%\bin\java.exe" "%PREFIX%\opt\temurin\bin\java.exe"

:: Set environment variables
set "JAVA_HOME=%PREFIX%\opt\temurin"
set "PATH=%JAVA_HOME%\bin;%PATH%"
set "JAVA_LD_LIBRARY_PATH=%JAVA_HOME%\lib\server"

:: Run java -Xshare:dump
java.exe -Xshare:dump

if errorlevel 1 exit 1
