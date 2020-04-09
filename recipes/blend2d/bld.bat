setlocal EnableDelayedExpansion

cd blend2d
mkdir build-%SUBDIR%-%c_compiler%
cd build-%SUBDIR%-%c_compiler%

cmake .. -G "Ninja" -D CMAKE_INSTALL_PREFIX=%LIBRARY_PREFIX%  -DCMAKE_BUILD_TYPE=Release 
if errorlevel 1 exit /b 1
cmake --build . --target install
if errorlevel 1 exit /b 1