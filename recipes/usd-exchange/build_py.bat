@echo on

copy /Y "%RECIPE_DIR%\python\CMakeLists.txt" "%SRC_DIR%\CMakeLists.txt"
if errorlevel 1 exit /b 1

cmake -S "%SRC_DIR%" -B build -G Ninja ^
  %CMAKE_ARGS% ^
  -DCMAKE_INSTALL_PREFIX="%LIBRARY_PREFIX%" ^
  -DCMAKE_BUILD_TYPE=Release ^
  -DPython_EXECUTABLE="%PYTHON%" ^
  -DUSDEX_VERSION="%PKG_VERSION%"
if errorlevel 1 exit /b 1

cmake --build build -j%CPU_COUNT%
if errorlevel 1 exit /b 1

cmake --install build
if errorlevel 1 exit /b 1
