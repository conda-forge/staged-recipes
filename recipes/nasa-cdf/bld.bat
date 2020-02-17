copy %RECIPE_DIR%\CMakeLists_root.txt CMakeLists.txt
copy %RECIPE_DIR%\CMakeLists_tools.txt src\tools\CMakeLists.txt
copy %RECIPE_DIR%\CMakeLists_lib.txt src\lib\CMakeLists.txt
mkdir build
cd build
cmake -G "%CMAKE_GENERATOR%" -DCMAKE_INSTALL_PREFIX=%LIBRARY_PREFIX% ..
if errorlevel 1 exit /b 1
cmake --build . --target install --config Release