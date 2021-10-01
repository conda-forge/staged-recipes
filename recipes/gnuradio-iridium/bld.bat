setlocal EnableDelayedExpansion
@echo on

copy "%RECIPE_DIR%\gr-iridium-LICENSE" "LICENSE"

:: Make a build folder and change to it
mkdir build
cd build

:: configure
:: enable components explicitly so we get build error when unsatisfied
cmake -G "Ninja" ^
    -DCMAKE_BUILD_TYPE:STRING=Release ^
    -DCMAKE_INSTALL_PREFIX:PATH="%LIBRARY_PREFIX%" ^
    -DCMAKE_PREFIX_PATH:PATH="%LIBRARY_PREFIX%" ^
    -DGR_PYTHON_DIR:PATH="%SP_DIR%" ^
    -DENABLE_DOXYGEN=OFF ^
    ..
if errorlevel 1 exit 1

:: build
cmake --build . --config Release -- -j%CPU_COUNT%
if errorlevel 1 exit 1

:: install
cmake --build . --config Release --target install
if errorlevel 1 exit 1
