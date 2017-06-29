mkdir build
cd build
cmake -G "%CMAKE_GENERATOR%" -DCMAKE_INSTALL_PREFIX="%LIBRARY_PREFIX%" ..
cmake --build . --config Release --
