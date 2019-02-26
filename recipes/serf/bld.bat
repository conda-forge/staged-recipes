copy %RECIPE_DIR%\CMakeLists.txt .\CMakeLists.txt

set CMAKE_CONFIG=Release

mkdir cmake_build_%CMAKE_CONFIG%
cd cmake_build_%CMAKE_CONFIG%

cmake -G "%CMAKE_GENERATOR%" ^
      -DCMAKE_BUILD_TYPE:STRING=%CMAKE_CONFIG% ^
      -DCMAKE_INSTALL_PREFIX:PATH=%LIBRARY_PREFIX% ^
      ..

cmake --build . --target INSTALL --config %CMAKE_CONFIG%
if errorlevel 1 exit 1

robocopy %SRC_DIR% %LIBRARY_INC% *.h /E
if %ERRORLEVEL% geq 8 exit 1
