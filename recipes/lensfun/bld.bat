@echo on
set BUILD_DIR=%SRC_DIR%\b
mkdir %BUILD_DIR%
cd %BUILD_DIR%

echo "%SRC_DIR%"

set CMAKE_CONFIG="Release"
set LD_LIBRARY_PATH=%LIBRARY_LIB%

cmake -G "%CMAKE_GENERATOR%" ^
      -D CMAKE_BUILD_TYPE="%CMAKE_CONFIG%" ^
      -D CMAKE_PREFIX_PATH="%LIBRARY_PREFIX%" ^
      -D CMAKE_INSTALL_PREFIX="%LIBRARY_PREFIX%" ^
      -D CMAKE_LIBRARY_PATH="%LIBRARY_LIB%" ^
      -D BUILD_SHARED_LIBS=ON ^
      ..
if errorlevel 1 exit 1

cmake --build . --config %CMAKE_CONFIG%
if errorlevel 1 exit 1

cmake --build . --config %CMAKE_CONFIG% --target install
if errorlevel 1 exit 1
