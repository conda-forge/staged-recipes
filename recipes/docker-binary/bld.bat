setlocal enableextensions enabledelayedexpansion


start /wait curl -sSL https://dockermsft.blob.core.windows.net/dockercontainer/docker-19-03-5.zip -o %SRC_DIR%\docker.zip
if %ERRORLEVEL% NEQ 0 goto FAIL

openssl sha256 docker.zip | sed 's/^.*= \(.*\)$/\1/' > checksum.txt
set /p CHECKSUM= < checksum.txt
if %CHECKSUM% NEQ 4ce8e7df20cfa7bfc6e7733f79d5dda4fda7aec3606168adfc8ea3f50261fdab goto FAIL

start /wait %PREFIX%\Library\usr\lib\p7zip\7za.exe x docker.zip -y -r -o%SRC_DIR%
if %ERRORLEVEL% NEQ 0 goto FAIL

xcopy %SRC_DIR%\docker %PREFIX%\Library\docker\ /E /F /Y
if %ERRORLEVEL% NEQ 0 goto FAIL

echo F | xcopy %RECIPE_DIR%\docker.cmd %PREFIX%\Scripts\docker.cmd /F /Y
if %ERRORLEVEL% NEQ 0 goto FAIL

exit /B 0

:FAIL
echo Command failed with ERRORLEVEL %ERRORLEVEL%
exit /B 1