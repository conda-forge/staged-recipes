cd build
if errorlevel 1 exit /b 1

cmake --install .
if errorlevel 1 exit /b 1

deltree /Y %LIBRARY_INC%
deltree /Y %LIBRARY_LIB%\\cmake
deltree /Y %LIBRARY_LIB%\\pkgconfig
