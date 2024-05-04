cmake -LAH -G "Ninja" ^
    -DCMAKE_PREFIX_PATH="%LIBRARY_PREFIX%" ^
    -DCMAKE_INSTALL_PREFIX="%LIBRARY_PREFIX%" ^
    .
if errorlevel 1 exit 1

cmake --build . --target install
if errorlevel 1 exit 1

ctest --output-on-failure --timeout 100
if errorlevel 1 exit 1
