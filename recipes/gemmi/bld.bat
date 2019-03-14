cmake ^
    -G "%CMAKE_GENERATOR%" ^
    -D CMAKE_PREFIX_PATH="%LIBRARY_PREFIX%" ^
    -D CMAKE_INSTALL_PREFIX="%LIBRARY_PREFIX%" ^
    -D CMAKE_BUILD_TYPE=Release ^
    .
if errorlevel 1 exit 1

cmake --build . --config Release
if errorlevel 1 exit 1

cp gemmi.exe "%LIBRARY_BIN%"
if errorlevel 1 exit 1

"%PYTHON%" -m pip install . --no-deps -vv
if errorlevel 1 exit 1
