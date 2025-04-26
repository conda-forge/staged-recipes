@echo on

:: Copy the CMakefile to the current directory
robocopy %RECIPE_DIR% %SRC_DIR% CMakeLists.txt > nul
if %ERRORLEVEL% GEQ 8 exit 1

:: Create an navigate to an out of source build directory
mkdir build
cd build

:: Configure the project using CMake
cmake -G Ninja ^
    %CMAKE_ARGS% ^
    -D BUILD_SHARED_LIBS=ON ^
    -D CMAKE_INSTALL_PREFIX=%LIBRARY_PREFIX% ^
    %SRC_DIR%
if errorlevel 1 exit 1

:: Build the project using CMake
cmake --build .
if errorlevel 1 exit 1

:: Install the project using CMake
cmake --build . --target install
if errorlevel 1 exit 1
