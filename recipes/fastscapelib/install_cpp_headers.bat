mkdir build_cpp
cd build_cpp

cmake %SRC_DIR% -G "%CMAKE_GENERATOR%" ^
                -D VERSION_TAG=%PKG_VERSION% ^
                -D BUILD_TESTS=OFF ^
                -D CMAKE_INSTALL_PREFIX=%LIBRARY_PREFIX%
if errorlevel 1 exit 1

cmake --build . --target install
if errorlevel 1 exit 1
