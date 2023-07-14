setlocal EnableDelayedExpansion
@echo on

cd src\algorithms\libs\volk_gnsssdr_module\volk_gnsssdr

:: Make a build folder and change to it
mkdir forgebuild
if errorlevel 1 exit 1
cd forgebuild
if errorlevel 1 exit 1

:: configure
cmake -G "Ninja" ^
    -DCMAKE_BUILD_TYPE=Release ^
    -DCMAKE_INSTALL_PREFIX="%LIBRARY_PREFIX%" ^
    -DCMAKE_PREFIX_PATH="%LIBRARY_PREFIX%" ^
    -DVOLK_PYTHON_DIR="%SRC_DIR%\_noinstall\site-packages" ^
    -DORCC_EXECUTABLE="%BUILD_PREFIX%\Library\bin\orcc.exe" ^
    -DENABLE_ORC=ON ^
    -DENABLE_PROFILING=OFF ^
    -DENABLE_STRIP=ON ^
    -DENABLE_TESTING=ON ^
    ..
if errorlevel 1 exit 1

:: build
cmake --build . --config Release
if errorlevel 1 exit 1

:: test
ctest --build-config Release --output-on-failure --timeout 120 -j%CPU_COUNT%
if errorlevel 1 exit 1

:: install
cmake --build . --config Release --target install
if errorlevel 1 exit 1

:: don't include volk_gnsssdr_modtool, we're skipping the modtool python lib
cmake -E rm "%LIBRARY_BIN%\volk_gnsssdr_modtool.py"
