set LUA_LIB_NAME=lua
if errorlevel 1 exit /b 1

set LUA_LIB=%LIBRARY_LIB%
if errorlevel 1 exit /b 1

cd /D "%SRC_DIR%"
if errorlevel 1 exit /b 1

python -m pip install . -vv --no-build-isolation --config-settings=build-args=--no-default-features
if errorlevel 1 exit /b 1

powershell -NoProfile -Command "Start-Sleep -Seconds 5"
if errorlevel 1 exit /b 1
