mkdir build
cd build
cmake \
    -G "Visual Studio 15 2017 Win64" \
    -DCMAKE_INSTALL_PREFIX=%PREFIX% \
    -DCMAKE_PREFIX_PATH=%PREFIX% \
    -DJKQtPlotter_BUILD_EXAMPLES=OFF \
    -DJKQtPlotter_BUILD_STATIC_LIBS=OFF \
    -DCMAKE_BUILD_TYPE=Release \
    ..
if errorlevel 1 exit 1
cmake --build . --config Release --target install
if errorlevel 1 exit 1
