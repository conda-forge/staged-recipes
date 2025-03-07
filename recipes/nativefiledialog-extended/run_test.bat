setlocal EnableDelayedExpansion

cd test
mkdir build

:: Compile basic example that links nfd
cd build
cmake -GNinja -DCMAKE_BUILD_TYPE=Release ..
if errorlevel 1 exit 1

cmake --build . --config Release
if errorlevel 1 exit 1
