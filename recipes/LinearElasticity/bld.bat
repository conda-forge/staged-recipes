cmake -G"NMake Makefiles JOM" ^
      -D CMAKE_BUILD_TYPE=Release ^
      -D "CMAKE_INSTALL_PREFIX=%PREFIX%" ^
      -S . -B build

if errorlevel 1 exit 1
cmake --build .\build --config Release --verbose
if errorlevel 1 exit 1
cmake --install .\build --verbose
