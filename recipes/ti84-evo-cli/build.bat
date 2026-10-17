@echo off
setlocal

call gradlew.bat cliJar --no-daemon --no-build-cache
if errorlevel 1 exit /b 1

if not exist "%PREFIX%\share\ti84-evo" mkdir "%PREFIX%\share\ti84-evo"
if not exist "%PREFIX%\bin" mkdir "%PREFIX%\bin"
if not exist "%PREFIX%\Scripts" mkdir "%PREFIX%\Scripts"

copy /Y "build\libs\ti84-evo-cli.jar" "%PREFIX%\share\ti84-evo\ti84-evo-cli.jar" || exit /b 1
copy /Y "src\cli\scripts\ti84-evo.ps1" "%PREFIX%\share\ti84-evo\ti84-evo.ps1" || exit /b 1
copy /Y "packaging\conda\ti84-evo" "%PREFIX%\bin\ti84-evo" || exit /b 1
copy /Y "packaging\conda\ti84-evo.bat" "%PREFIX%\Scripts\ti84-evo.bat" || exit /b 1
