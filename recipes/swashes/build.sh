cmake -DCMAKE_BUILD_TYPE=Release CMakeLists.txt
cmake --build .
mkdir -p $PREFIX/bin
install bin/swashes $PREFIX/bin
