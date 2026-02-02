@echo on

cmake %CMAKE_ARGS% -GNinja ^
    -DCMAKE_BUILD_TYPE=Release ^
    -DCMAKE_INSTALL_PREFIX="%LIBRARY_PREFIX%" ^
    -B build ^
    .
if errorlevel 1 exit 1

cmake --build build --target libstim
if errorlevel 1 exit 1

cmake --install build
if errorlevel 1 exit 1
