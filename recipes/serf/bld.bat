COPY %RECIPE_DIR%\CMakeLists.txt .\CMakeLists.txt

mkdir cmake_build
IF ERRORLEVEL 1 EXIT 1

pushd cmake_build
IF ERRORLEVEL 1 EXIT 1

cmake -G "%CMAKE_GENERATOR%" ^
      -DCMAKE_BUILD_TYPE=Release ^
      -DCMAKE_INSTALL_PREFIX=%LIBRARY_PREFIX% ^
      ..
IF ERRORLEVEL 1 EXIT 1

cmake --build . --target INSTALL --config Release
IF ERRORLEVEL 1 EXIT 1

ROBOCOPY %SRC_DIR% %LIBRARY_INC% *.h /E
If %ERRORLEVEL% GEQ 8 EXIT 1
REM MOVE %SRC_DIR%\auth %LIBRARY_INC%\
REM MOVE %SRC_DIR%\buckets %LIBRARY_INC%\
