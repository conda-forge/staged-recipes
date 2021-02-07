mkdir build
cd build

cmake                    ^
    -DBUILD_DOCS=OFF     ^
    -DBUILD_EXAMPLES=OFF ^
    -DBUILD_TESTS=OFF    ^
    -DCMAKE_INSTALL_PREFIX=%LIBRARY_PREFIX% \
    ..


cmake --build . --target install --config Release
