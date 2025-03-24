:: Borrowed from LibTurboJpeg
:: Build step

mkdir build
cd  build

cmake .. -GNinja ^
    -D CMAKE_INSTALL_PREFIX=%LIBRARY_PREFIX% ^
    -D CMAKE_PREFIX_PATH=%LIBRARY_PREFIX% ^
    -D CMAKE_INSTALL_PYTHON_LIBDIR=%SP_DIR% ^
    -D CMAKE_BUILD_TYPE=Release ^
    -D CMAKE_WINDOWS_EXPORT_ALL_SYMBOLS=TRUE ^
    -D IRIS_BUILD_SHARED=OFF ^
    -D IRIS_BUILD_STATIC=OFF ^
    -D IRIS_BUILD_ENCODER=OFF ^
    -D IRIS_BUILD_DEPENDENCIES=OFF ^
    -D IRIS_BUILD_PYTHON=ON ^
    %SRC_DIR%
if errorlevel 1 exit 1

cmake --build . --config Release
if errorlevel 1 exit 1

:: Install step
cmake --install .
if errorlevel 1 exit 1