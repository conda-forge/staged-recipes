cmake -DCMAKE_BUILD_TYPE=Release CMakeLists.txt
cmake --build .
install -t $PREFIX/bin bin/swashes
