@echo on

cmake %SRC_DIR% ^
    -B build ^
    -G Ninja ^
    -DCMAKE_INSTALL_PREFIX=%LIBRARY_PREFIX% ^
    -DCMAKE_BUILD_TYPE=Release ^
    -DPARAMETRIC_BUILD_TESTS=OFF ^
    -DPARAMETRIC_BUILD_EXAMPLES=OFF ^
    -DPARAMETRIC_BUILD_DOCS=OFF ^
    %CMAKE_ARGS%
if errorlevel 1 exit 1

cmake --build build --target install --config Release
if errorlevel 1 exit 1