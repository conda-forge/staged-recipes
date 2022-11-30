setlocal EnableDelayedExpansion
@echo on

:: Make a build folder and change to it
mkdir build
if errorlevel 1 exit 1
cd build
if errorlevel 1 exit 1

:: configure
cmake -G "Ninja" ^
    -DCMAKE_BUILD_TYPE=Release ^
    -DCMAKE_INSTALL_PREFIX="%LIBRARY_PREFIX%" ^
    -DCMAKE_PREFIX_PATH="%LIBRARY_PREFIX%" ^
    -DCMAKE_WINDOWS_EXPORT_ALL_SYMBOLS=ON ^
    ..
if errorlevel 1 exit 1

:: build
cmake --build . --config Release
if errorlevel 1 exit 1
cmake --build . --config Release --target shim
if errorlevel 1 exit 1

:: install
cmake --build . --config Release --target install
if errorlevel 1 exit 1

cmake -E rm -f %LIBRARY_LIB%/correct_static.lib %LIBRARY_LIB%/fec_static.lib
if errorlevel 1 exit 1
