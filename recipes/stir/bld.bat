mkdir build
cd build

:: Configure.
cmake -G "%CMAKE_GENERATOR%" ^
      -D CMAKE_INSTALL_PREFIX=%LIBRARY_PREFIX% ^
      -D PYTHON_DEST=%SP_DIR% ^
      -D BUILD_SWIG_PYTHON:BOOL=ON ^
      -D CMAKE_BUILD_TYPE=Release ^
      %SRC_DIR%
if errorlevel 1 exit 1

:: Build.
cmake --build . --config Release
if errorlevel 1 exit 1

:: Install.
cmake --build . --target install --config Release
if errorlevel 1 exit 1

