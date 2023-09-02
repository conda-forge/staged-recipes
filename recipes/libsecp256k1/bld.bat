setlocal EnableDelayedExpansion
@echo on

set BUILD_DIR=build

mkdir "%BUILD_DIR%"
if errorlevel 1 exit 1

cd "%BUILD_DIR%"
if errorlevel 1 exit 1

cmake .. -DCMAKE_PREFIX_PATH="%PREFIX%" -DCMAKE_INSTALL_PREFIX="%LIBRARY_PREFIX%" "%SECP256K1_OPTIONS%"
if errorlevel 1 exit 1

cmake --build . --target install "%CMAKE_BUILD_OPTIONS%"
if errorlevel 1 exit 1

