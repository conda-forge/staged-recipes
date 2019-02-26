copy %RECIPE_DIR%\CMakeLists.txt .\CMakeLists.txt

mkdir cmake_build
pushd cmake_build

cmake -G "%CMAKE_GENERATOR%" ^
      -DCMAKE_BUILD_TYPE:STRING=Release ^
      -DCMAKE_INSTALL_PREFIX:PATH=%LIBRARY_PREFIX% ^
      ..

cmake --build . --target INSTALL --config Release
if errorlevel 1 exit 1

robocopy %SRC_DIR% %LIBRARY_INC% *.h /E
if %ERRORLEVEL% geq 8 exit 1
