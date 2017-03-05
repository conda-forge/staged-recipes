c++ -std=c++11 -I $PREFIX/include $RECIPE_DIR/test.cpp $PREFIX/lib/libHalide.a -lz -o test
./test
