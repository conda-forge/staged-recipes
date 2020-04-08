cd blend2d
mkdir build-$SUBDIR-$c_compiler
cd build-$SUBDIR-$c_compiler

cmake .. -G "Ninja" -D CMAKE_INSTALL_PREFIX=$LIBRARY_PREFIX  -DCMAKE_BUILD_TYPE=Release -DBLEND2D_STATIC=TRUE           
cmake --build . --target install




