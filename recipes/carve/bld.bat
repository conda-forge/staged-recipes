cmake -DCMAKE_INSTALL_PREFIX="%LIBRARY_PREFIX%" . 
cmake --build . --config release
cmake --install . --config release 
