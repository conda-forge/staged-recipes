
cmake -LAH -G "Ninja" ^
    -DCMAKE_PREFIX_PATH="%LIBRARY_PREFIX%" ^
    -DCMAKE_INSTALL_PREFIX="%LIBRARY_PREFIX%" ^
    -DCMAKE_UNITY_BUILD=ON ^
    -DPython_FIND_STRATEGY=LOCATION ^
    -DPython_ROOT_DIR="%PREFIX%" ^
    -DOTMESHING_PYTHON_MODULE_PATH=../Lib/site-packages ^
    -DSWIG_COMPILE_FLAGS="/DPy_LIMITED_API=0x030A0000" -DUSE_PYTHON_SABI=ON ^
    -B build .
if errorlevel 1 exit 1

cmake --build build --target install --config Release --parallel %CPU_COUNT%
if errorlevel 1 exit 1

ctest --test-dir build -R pyinstallcheck --output-on-failure --timeout 100 -j%CPU_COUNT%
if errorlevel 1 exit 1
