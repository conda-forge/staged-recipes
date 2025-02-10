@REM NOTICE: Keep synchronized with build.sh

setlocal enableextensions
if errorlevel 1 echo Unable to enable extensions

mkdir %CD%\build

if %errorlevel% neq 0 exit /b %errorlevel%

set BLDDIR=%CD%\build

if %errorlevel% neq 0 exit /b %errorlevel%

cmake ^
    -B %BLDDIR% ^
    -S %CD% ^
    %CMAKE_ARGS% ^
    -DCMAKE_INSTALL_PREFIX="%PREFIX%" ^
    -DCMAKE_INSTALL_LIBDIR=lib ^
    -DCMAKE_BUILD_TYPE=Release ^
    -DREADOUT_TESTS=OFF ^
    -DREADOUT_USE_CONAN=OFF ^
    -DHIGHFIVE_USE_INSTALL_DEPS=ON

if %errorlevel% neq 0 exit /b %errorlevel%

cmake --build %BLDDIR% --config Release -j

if %errorlevel% neq 0 exit /b %errorlevel%

cmake --build %BLDDIR% --target install --config Release

if %errorlevel% neq 0 exit /b %errorlevel%

