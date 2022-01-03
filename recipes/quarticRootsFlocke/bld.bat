set CMAKE_ARGS=%CMAKE_ARGS% -B build
set CMAKE_ARGS=%CMAKE_ARGS% -S .
set CMAKE_ARGS=%CMAKE_ARGS% -G Ninja
set CMAKE_ARGS=%CMAKE_ARGS% -DENABLE_CTEST=ON
set CMAKE_ARGS=%CMAKE_ARGS% -DBUILD_EXECUTABLE=ON
set CMAKE_ARGS=%CMAKE_ARGS% -DCMAKE_BUILD_TYPE=Release
set CMAKE_ARGS=%CMAKE_ARGS% -DCMAKE_PREFIX_PATH="%LIBRARY_PREFIX%"
set CMAKE_ARGS=%CMAKE_ARGS% -DCMAKE_INSTALL_PREFIX:PATH="%LIBRARY_PREFIX%"
set CMAKE_ARGS=%CMAKE_ARGS% -DVERSION=1.0.0

echo "CMAKE_ARGS: %CMAKE_ARGS%"
echo "PREFIX: %PREFIX%"

cmake %CMAKE_ARGS%
if errorlevel 1 exit 1

cmake --build build --config Release
if errorlevel 1 exit 1

cmake --build build --target test
if errorlevel 1 exit 1

cmake --install build
if errorlevel 1 exit 1
