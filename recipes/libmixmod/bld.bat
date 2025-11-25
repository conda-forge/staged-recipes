
cmake -LAH -G "Ninja" ^
    -DCMAKE_INSTALL_PREFIX="%LIBRARY_PREFIX%" ^
    -DCMAKE_PREFIX_PATH="%LIBRARY_PREFIX%" ^
    -DCMAKE_UNITY_BUILD=ON ^
    -B build .
if errorlevel 1 exit 1

cmake --build build --target install --parallel %CPU_COUNT%
if errorlevel 1 exit 1

ctest --test-dir build --output-on-failure -j%CPU_COUNT%
if errorlevel 1 exit 1
