setlocal EnableDelayedExpansion
@echo on

set BUILD_DIR=build

mkdir "%BUILD_DIR%"
if errorlevel 1 exit 1

cd "%BUILD_DIR%"
if errorlevel 1 exit 1

cmake .. -DCMAKE_PREFIX_PATH="%PREFIX%" -DCMAKE_INSTALL_PREFIX="%LIBRARY_PREFIX%" -DCMAKE_BUILD_TYPE=Release
if errorlevel 1 exit 1

cmake --build . --config Release --target install
if errorlevel 1 exit 1