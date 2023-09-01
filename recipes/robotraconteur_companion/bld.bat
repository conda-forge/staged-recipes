@echo off

md build2
cd build2
if %errorlevel% neq 0 exit /b %errorlevel%
cmake -GNinja -DBUILD_GEN=ON -DBUILD_PYTHON3=ON ^
  -DCMAKE_INSTALL_PREFIX:PATH="%LIBRARY_PREFIX%" ^
  -DCMAKE_PREFIX_PATH:PATH="%LIBRARY_PREFIX%" ^
  -DCMAKE_BUILD_TYPE:STRING=Release ^
  -DBUILD_SHARED_LIBS:BOOL=ON ^
  ..
if %errorlevel% neq 0 exit /b %errorlevel%
cmake --build . --config Release -j 4
if %errorlevel% neq 0 exit /b %errorlevel%
cmake --build . --config Release --target install
