REM Build from temp paths outside conda-build's work dir to avoid the
REM Windows cleanup race we hit with the recipe.yaml/rattler-build route.
set BUILD_SRC=%TEMP%\burner-redis-src-%RANDOM%%RANDOM%
if errorlevel 1 exit /b 1

powershell -NoProfile -Command "Copy-Item -LiteralPath $env:SRC_DIR -Destination $env:BUILD_SRC -Recurse -Force"
if errorlevel 1 exit /b 1

set CARGO_TARGET_DIR=%TEMP%\burner-redis-cargo-target-%RANDOM%%RANDOM%
if errorlevel 1 exit /b 1

set LUA_LIB_NAME=lua
if errorlevel 1 exit /b 1

set LUA_LIB=%LIBRARY_LIB%
if errorlevel 1 exit /b 1

cd /D "%BUILD_SRC%"
if errorlevel 1 exit /b 1

python -m pip install "%BUILD_SRC%" -vv --no-build-isolation --config-settings=build-args=--no-default-features
if errorlevel 1 exit /b 1

powershell -NoProfile -Command "Start-Sleep -Seconds 5"
if errorlevel 1 exit /b 1
