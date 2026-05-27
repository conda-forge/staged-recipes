@echo on
setlocal enableextensions enabledelayedexpansion

REM Binary repackage of MongoDB Community Server (Windows). No compilation.
REM On Windows, conda-forge convention installs binaries to %LIBRARY_BIN%
REM (= %PREFIX%\Library\bin), which is on PATH when the env is activated.

if not exist "bin\mongod.exe" (
    echo ERROR: expected bin\mongod.exe in the extracted ZIP 1>&2
    dir 1>&2
    exit /B 1
)
if not exist "bin\mongos.exe" (
    echo ERROR: expected bin\mongos.exe in the extracted ZIP 1>&2
    exit /B 1
)

if not exist "%LIBRARY_BIN%" mkdir "%LIBRARY_BIN%"
if errorlevel 1 exit /B 1

copy /Y "bin\mongod.exe" "%LIBRARY_BIN%\mongod.exe"
if errorlevel 1 exit /B 1
copy /Y "bin\mongos.exe" "%LIBRARY_BIN%\mongos.exe"
if errorlevel 1 exit /B 1

if not exist "%PREFIX%\share\mongodb-server-binary" mkdir "%PREFIX%\share\mongodb-server-binary"
for %%f in (LICENSE-Community.txt THIRD-PARTY-NOTICES MPL-2 README) do (
    if exist "%%f" copy /Y "%%f" "%PREFIX%\share\mongodb-server-binary\"
)

"%LIBRARY_BIN%\mongod.exe" --version
if errorlevel 1 exit /B 1
"%LIBRARY_BIN%\mongos.exe" --version
if errorlevel 1 exit /B 1

exit /B 0
