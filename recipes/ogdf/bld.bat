md build
cd build

msbuild -version

set MAKEFLAGS=

cmake .. -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX=%PREFIX%
if errorlevel 1 exit /b 1

cmake --build . --config Release --target install
if errorlevel 1 exit /b 1
