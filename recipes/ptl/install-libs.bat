cd build
if errorlevel 1 exit /b 1

cmake --install .
if errorlevel 1 exit /b 1

deltree /Y %PREFIX%\\include
deltree /Y %PREFIX%\\lib\\cmake
deltree /Y %PREFIX%\\lib\\pkgconfig
