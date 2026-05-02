mkdir build
cd build
cmake .. -DCMAKE_INSTALL_PREFIX="%LIBRARY_PREFIX%" -DCMAKE_BUILD_TYPE=Release -G Ninja
cmake --build .
cmake --install .
