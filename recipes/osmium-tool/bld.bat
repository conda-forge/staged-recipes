setlocal EnableDelayedExpansion


set BUILD_DIR=build

mkdir %BUILD_DIR%

cmake -S osmium-tool ^
 -B %BUILD_DIR% ^
 -G "Ninja" ^
 -D CMAKE_BUILD_TYPE=Release ^
 -D CMAKE_INSTALL_PREFIX="%LIBRARY_PREFIX%"

if errorlevel 1 exit 1

cmake --build %BUILD_DIR% --target all

if errorlevel 1 exit 1

cmake --build %BUILD_DIR% --target install

if errorlevel 1 exit 1
