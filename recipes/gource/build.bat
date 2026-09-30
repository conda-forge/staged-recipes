@echo on

copy "%RECIPE_DIR%\CMakeLists.txt" .
if errorlevel 1 exit 1
xcopy /E /I "%RECIPE_DIR%\msvc" msvc
if errorlevel 1 exit 1

cmake %CMAKE_ARGS% -G Ninja ^
    -DCMAKE_BUILD_TYPE=Release ^
    -DCMAKE_INSTALL_PREFIX="%LIBRARY_PREFIX%" ^
    -DCMAKE_PREFIX_PATH="%LIBRARY_PREFIX%" ^
    -B build
if errorlevel 1 exit 1

cmake --build build --parallel %CPU_COUNT%
if errorlevel 1 exit 1

cmake --install build
if errorlevel 1 exit 1
