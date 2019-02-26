COPY %RECIPE_DIR%\CMakeLists.txt .\CMakeLists.txt

mkdir cmake_build
pushd cmake_build

cmake -G "%CMAKE_GENERATOR%" ^
      -DCMAKE_BUILD_TYPE=Release ^
      -DCMAKE_INSTALL_PREFIX=%LIBRARY_PREFIX% ^
      ..

cmake --build . --target INSTALL --config Release
IF ERRORLEVEL 1 EXIT 1

ROBOCOPY %SRC_DIR% %LIBRARY_INC% *.h /E
If %ERRORLEVEL% GEQ 8 EXIT 1
