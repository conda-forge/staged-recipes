@echo ON

mkdir build
if %ERRORLEVEL% NEQ 0 exit /b %ERRORLEVEL%

cd build
if %ERRORLEVEL% NEQ 0 exit /b %ERRORLEVEL%

cmake %CMAKE_ARGS% ^
    -G "Ninja" ^
    -DCMAKE_BUILD_TYPE=Release ^
    -DCMAKE_INSTALL_PREFIX=%LIBRARY_PREFIX% ^
    ..
if %ERRORLEVEL% NEQ 0 exit /b %ERRORLEVEL%

cmake --build . --config Release --target install
if %ERRORLEVEL% NEQ 0 exit /b %ERRORLEVEL%
