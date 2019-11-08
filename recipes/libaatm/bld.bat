setlocal EnableDelayedExpansion

:: Make a build folder and change to it.
mkdir build
cd build

:: Configure using the CMakeFiles
cmake -G "%CMAKE_GENERATOR%" ^
      -DCMAKE_INSTALL_PREFIX:PATH="%LIBRARY_PREFIX%" ^
      -DCMAKE_PREFIX_PATH:PATH="%LIBRARY_PREFIX%" ^
      -DCMAKE_BUILD_TYPE:STRING=Release ^
      %SRC_DIR%
if errorlevel 1 exit /b 1

:: Build and Install
cmake --build . --config Release --target install
if errorlevel 1 exit /b 1

:: Test
ctest -C Release
if errorlevel 1 exit 1
