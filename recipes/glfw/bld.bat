mkdir build
cd build

cmake  -G "%CMAKE_GENERATOR%"        ^
    -DCMAKE_PREFIX_PATH=%PREFIX%     ^
    -DCMAKE_INSTALL_PREFIX=%LIBRARY_PREFIX% ^
    -DBUILD_SHARED_LIBS=ON           ^
    -DGLFW_BUILD_EXAMPLES=OFF        ^
    -DGLFW_BUILD_TESTS=OFF           ^
    -DGLFW_BUILD_DOCS=OFF            ^
    ..
if errorlevel 1 exit 1

cmake --build . --target install --config Release
if errorlevel 1 exit 1