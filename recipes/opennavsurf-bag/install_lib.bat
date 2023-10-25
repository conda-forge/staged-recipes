setlocal EnableDelayedExpansion

cmake --build build --target install
if errorlevel 1 exit /b 1
