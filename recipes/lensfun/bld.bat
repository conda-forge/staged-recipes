pushd . && mkdir build && cd build
if errorlevel 1 exit 1

cmake -G "%CMAKE_GENERATOR%" ^
    -D CMAKE_BUILD_TYPE=Release ^
    -D CMAKE_PREFIX_PATH=%LIBRARY_PREFIX% ^
    -D CMAKE_INSTALL_PREFIX:PATH=%LIBRARY_PREFIX% ^
    %SRC_DIR%
if errorlevel 1 exit 1

cmake --build . --config Release --target install
if errorlevel 1 exit 1

popd && rd /q /s build
if errorlevel 1 exit 1
