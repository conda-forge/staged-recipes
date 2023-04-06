cmake -S . -B build -G "Ninja" -DCMAKE_BUILD_TYPE=Release -DSEASOCKS_SHARED=ON -DUNITTESTS=OFF -SEASOCKS_EXAMPLE_APP=OFF -DCMAKE_INSTALL_PREFIX=%LIBRARY_PREFIX%
cmake --build build --config Release --target install
