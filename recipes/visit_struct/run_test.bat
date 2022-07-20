setlocal EnableDelayedExpansion

cd test

cmake -GNinja -DCMAKE_BUILD_TYPE=Release .
if errorlevel 1 exit 1

cmake --build . --config Release
if errorlevel 1 exit 1

:: Run example
.\visit_struct_example.exe
if errorlevel 1 exit 1
