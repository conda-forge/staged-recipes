mkdir build && cd build

cmake -GNinja ^
    -DCMAKE_BUILD_TYPE=Release ^
    -DCMAKE_INSTALL_PREFIX="%LIBRARY_PREFIX%" ^
    -DCMAKE_PREFIX_PATH="%LIBRARY_PREFIX%" ^
    %SRC_DIR%

cmake --build . --config Release
ctest --output-on-failure -C Release
cmake --build . --config Release --target install

cd %SRC_DIR% && rd /q /s build
