setlocal EnableDelayedExpansion

mkdir %SRC_DIR%\build
cd %SRC_DIR%\build

cmake -GNinja ^
    -DCMAKE_INSTALL_PREFIX:PATH="%LIBRARY_PREFIX%" ^
    -DCMAKE_PREFIX_PATH:PATH="%LIBRARY_PREFIX%" ^
    -DCMAKE_BUILD_TYPE:STRING=Release ^
    ..
if errorlevel 1 exit \b 1

cmake --build .
if errorlevel 1 exit \b 1

ctest --extra-verbose --output-on-failure .
if errorlevel 1 exit \b 1

cmake --install .
if errorlevel 1 exit \b 1

rmdir /s /q %LIBRARY_PREFIX%\parc
