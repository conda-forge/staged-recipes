@echo on

cmake -LAH -G "Ninja" ^
    %CMAKE_ARGS% ^
    -B build CDT
if errorlevel 1 exit 1

cmake --build build --target install --config Release
if errorlevel 1 exit 1

