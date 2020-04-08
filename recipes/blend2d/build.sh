cd blend2d
mkdir build-$SUBDIR-$c_compiler
cd build-$SUBDIR-$c_compiler

cmake .. -G "Ninja" -D CMAKE_INSTALL_PREFIX=$LIBRARY_PREFIX  -DCMAKE_BUILD_TYPE=Release -DBLEND2D_STATIC=true          
cmake --build . --target install


cmake .. -G "Ninja" -D CMAKE_INSTALL_PREFIX=$LIBRARY_PREFIX  -DCMAKE_BUILD_TYPE=Release -DBLEND2D_STATIC=false         
cmake --build . --target install




