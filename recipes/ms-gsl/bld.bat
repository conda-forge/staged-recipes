cmake -S . -B build -G "Ninja" -DGSL_TEST=OFF -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX=%LIBRARY_PREFIX%
cmake --build build --config Release --target install
